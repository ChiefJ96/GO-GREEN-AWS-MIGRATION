provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.name_prefix}-private-${count.index + 1}"
  }
}

resource "aws_subnet" "database" {
  count             = length(var.database_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.name_prefix}-database-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

resource "aws_eip" "nat" {
  count = length(aws_subnet.public)

  tags = {
    Name = "${var.name_prefix}-nat-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "natgw" {
  count         = length(aws_subnet.public)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.name_prefix}-natgw-${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-public-rt"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = length(aws_subnet.private)
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-private-rt-${count.index + 1}"
  }
}

resource "aws_route" "private_nat" {
  count                  = length(aws_route_table.private)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw[count.index].id
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table" "database" {
  count  = length(aws_subnet.database)
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-database-rt-${count.index + 1}"
  }
}

resource "aws_route" "database_nat" {
  count                  = length(aws_route_table.database)
  route_table_id         = aws_route_table.database[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw[count.index].id
}

resource "aws_route_table_association" "database_assoc" {
  count          = length(aws_subnet.database)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database[count.index].id
}

# Basic Network ACL for public subnets
resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-public-nacl"
  }
}

resource "aws_network_acl_rule" "public_in_http" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  protocol       = "6"
  rule_action   = "allow"
  egress         = false
  cidr_block     = "0.0.0.0/0"
  from_port     = 80
  to_port       = 80
}

resource "aws_network_acl_rule" "public_in_https" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 110
  protocol       = "6"
  rule_action   = "allow"
  egress         = false
  cidr_block     = "0.0.0.0/0"
  from_port     = 443
  to_port       = 443
}

resource "aws_network_acl_rule" "public_out_all" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  protocol       = "-1"
  rule_action   = "allow"
  egress         = true
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_association" "public_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  network_acl_id = aws_network_acl.public.id
}

# Network ACL for private subnets - allow outgoing, established incoming
resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-private-nacl"
  }
}

resource "aws_network_acl_rule" "private_in_established" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100
  protocol       = "6"
  rule_action   = "allow"
  egress         = false
  cidr_block     = var.vpc_cidr
  from_port     = 1024
  to_port       = 65535
}

resource "aws_network_acl_rule" "private_out_all" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100
  protocol       = "-1"
  rule_action   = "allow"
  egress         = true
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_association" "private_assoc" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  network_acl_id = aws_network_acl.private.id
}

# Network ACL for database subnets similar to private
resource "aws_network_acl" "database" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-database-nacl"
  }
}

resource "aws_network_acl_rule" "database_in_established" {
  network_acl_id = aws_network_acl.database.id
  rule_number    = 100
  protocol       = "6"
  rule_action   = "allow"
  egress         = false
  cidr_block     = var.vpc_cidr
  from_port     = 1024
  to_port       = 65535
}

resource "aws_network_acl_rule" "database_out_all" {
  network_acl_id = aws_network_acl.database.id
  rule_number    = 100
  protocol       = "-1"
  rule_action   = "allow"
  egress         = true
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_association" "database_assoc" {
  count          = length(aws_subnet.database)
  subnet_id      = aws_subnet.database[count.index].id
  network_acl_id = aws_network_acl.database.id
}

