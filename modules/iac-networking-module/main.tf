# Local Variables for Naming Conventions
locals {
  # Naming convention for resources
  name_prefix = "${var.environment}-${var.project_name}"
  az_suffix = [
    for az in data.aws_availability_zones.available.names :
    regex("[0-9]+[a-z]$", az)
  ]

  # Common tags for all resources
  common_tags = {
    Environment = var.environment
    Managed_by  = var.managed_by
    Owner       = var.owner
    Project     = "${var.project_name}"
  }

  # Resource specific names
  vpc_name            = "${local.name_prefix}-vpc"
  igw_name            = "${local.name_prefix}-igw"
  public_subnet_name  = "${local.name_prefix}-public-subnet"
  private_subnet_name = "${local.name_prefix}-rds-subnet"
  public_rtb_name     = "${local.name_prefix}-public-rtb"
  private_rtb_name    = "${local.name_prefix}-private-rtb"
  app_subnet_name     = "${local.name_prefix}-app-subnet"
  nat_gateway_name    = "${local.name_prefix}-nat-gateway"
  elastic_ip_name     = "${local.name_prefix}-nat-eip"
}

# Local Variables for Subnet CIDR Blocks
locals {
  public_subnet_cidrs = [
    cidrsubnet(var.vpc_cidr, 8, 0),
    cidrsubnet(var.vpc_cidr, 8, 1),
    cidrsubnet(var.vpc_cidr, 8, 2)
  ]

  app_subnet_cidrs = [
    cidrsubnet(var.vpc_cidr, 8, 10),
    cidrsubnet(var.vpc_cidr, 8, 11),
    cidrsubnet(var.vpc_cidr, 8, 12)
  ]

  db_subnet_cidrs = [
    cidrsubnet(var.vpc_cidr, 8, 20),
    cidrsubnet(var.vpc_cidr, 8, 21),
    cidrsubnet(var.vpc_cidr, 8, 22)
  ]
}

# ---------------------------------------------------------------------
# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${local.vpc_name}"
  })
}

# Tag Default Route Table as Do Not Use
resource "aws_default_route_table" "do_not_use" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = merge(local.common_tags, {
    Name = "Default Route Table: Do Not Use"
  })
}

# Create Internet Gateway and Attach to VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_ssm_parameter.vpc_id.value

  tags = merge(local.common_tags, {
    Name = "${local.igw_name}"
  })
}

# Create 3 public subnets
resource "aws_subnet" "public" {
  count                   = var.availability_zones_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name  = "${local.public_subnet_name}"
    AName = "${local.public_subnet_name}-${data.aws_availability_zones.available.names[count.index]}"
    Type  = "Public"
  })
}

# Create 3 private App subnets
resource "aws_subnet" "app_private" {
  count             = var.availability_zones_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.app_subnet_cidrs[count.index]
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = merge(local.common_tags, {
    Name   = "${local.app_subnet_name}"
    AName  = "${local.app_subnet_name}-${data.aws_availability_zones.available.names[count.index]}"
    "Type" = "Private"
  })
}

# Create 3 DB Private subnets
resource "aws_subnet" "db_private" {
  count             = var.availability_zones_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.db_subnet_cidrs[count.index]
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = merge(local.common_tags, {
    Name                     = "${local.private_subnet_name}"
    AName                    = "${local.private_subnet_name}-${data.aws_availability_zones.available.names[count.index]}"
    "kubernetes.io/role/elb" = "1" # For EKS if needed later
    "Type"                   = "Private"
  })
}

# Create  EIP for NAT Gatewayr
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${local.elastic_ip_name}"
  })
}

# Create NAT Gateway In Public Subnet and Attach EIP
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(local.common_tags, {
    Name = "${local.nat_gateway_name}"
  })

  depends_on = [aws_eip.nat_eip]
}

# Create Private Route Table with Route to NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = var.rtb_cidr_block
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.private_rtb_name}"
  })
}

# Associate Private route table with private App subnets
resource "aws_route_table_association" "app_private" {
  count          = var.availability_zones_count
  subnet_id      = aws_subnet.app_private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Associate Private route table with private DB SUbnets
resource "aws_route_table_association" "db_private" {
  count          = var.availability_zones_count
  subnet_id      = aws_subnet.db_private[count.index].id
  route_table_id = aws_route_table.private.id

}

# Create Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_ssm_parameter.vpc_id.value

  route {
    cidr_block = var.rtb_cidr_block
    gateway_id = aws_ssm_parameter.igw_id.value
  }

  tags = merge(local.common_tags, {
    Name = local.public_rtb_name
  })
}

# Associate route table with public subnets
resource "aws_route_table_association" "public" {
  count          = var.availability_zones_count
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_ssm_parameter.public_rt_id.value
}

# -----------------------------------------------------------------------
# Save Networking Credentials in SSM Parameter Store
# -----------------------------------------------------------------------

# Store VPC ID in SSM
resource "aws_ssm_parameter" "vpc_id" {
  name       = "/${local.name_prefix}/vpc_id"
  type       = "SecureString"
  value      = aws_vpc.main.id
  tags       = local.common_tags
  depends_on = [aws_vpc.main]

}

# Store Public Subnet IDs in SSM
resource "aws_ssm_parameter" "public_subnet_ids" {
  name       = "/${local.name_prefix}/public_subnet_ids"
  type       = "StringList"
  value      = join(",", aws_subnet.public[*].id)
  depends_on = [aws_subnet.public]

  tags = local.common_tags
}

# Store First Public Subnet ID For JumpBox
resource "aws_ssm_parameter" "jumpbox_subnet" {
  name  = "/${local.name_prefix}/jumpbox_subnet"
  type  = "String"
  value = aws_subnet.public[0].id
}

# Store Private Subnet IDs in SSM
resource "aws_ssm_parameter" "app_subnet_ids" {
  name  = "/${local.name_prefix}/app_subnet_ids"
  type  = "StringList"
  value = join(",", aws_subnet.app_private[*].id)


  tags       = local.common_tags
  depends_on = [aws_subnet.app_private]
}

# Store DB Subnet IDs in SSM
resource "aws_ssm_parameter" "db_subnet_ids" {
  name  = "/${local.name_prefix}/db_subnet_ids"
  type  = "StringList"
  value = join(",", aws_subnet.db_private[*].id)

  tags       = local.common_tags
  depends_on = [aws_subnet.db_private]
}

# Store Internet Gateway ID in SSM
resource "aws_ssm_parameter" "igw_id" {
  name       = "/${local.name_prefix}/igw_id"
  type       = "String"
  value      = aws_internet_gateway.igw.id
  depends_on = [aws_internet_gateway.igw]

  tags = local.common_tags
}

# Store Public Route Table ID in SSM
resource "aws_ssm_parameter" "public_rt_id" {
  name       = "/${local.name_prefix}/public_rt_id"
  type       = "String"
  value      = aws_route_table.public.id
  depends_on = [aws_route_table.public]

  tags = local.common_tags
}

# Store Private Route Table ID in SSM
resource "aws_ssm_parameter" "private_rt_id" {
  name       = "/${local.name_prefix}/private_rt_id"
  type       = "String"
  value      = join(",", aws_route_table.private[*].id)
  depends_on = [aws_route_table.private]

  tags = local.common_tags
}

# Store NAT Gateway ID in SSM
resource "aws_ssm_parameter" "nat_id" {
  name       = "/${local.name_prefix}/nat_id"
  type       = "String"
  value      = join(",", aws_nat_gateway.nat[*].id)
  depends_on = [aws_nat_gateway.nat]

  tags = local.common_tags
}

##################################################################################
# Retrieve Networking Credentials from SSM Parameter Store
# Retrieve AVAILABILITY ZONES
data "aws_availability_zones" "available" {
  state = "available"
}

# Retrieve VPC ID from SSM Parameter Store
data "aws_ssm_parameter" "vpc_id" {
  name = "/${local.name_prefix}/vpc_id"

  depends_on = [aws_ssm_parameter.vpc_id]
}

# Retrieve Subnet IDS from SSM Parameter Store
data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${local.name_prefix}/public_subnet_ids"

  depends_on = [aws_ssm_parameter.public_subnet_ids]
}

# Retrieve App Private Subnet IDs from SSM Parameter Store
data "aws_ssm_parameter" "app_subnet_ids" {
  name = "/${local.name_prefix}/app_subnet_ids"

  depends_on = [aws_ssm_parameter.app_subnet_ids]
}

# Retrieve DB Private Subnet IDS from SSM Parameter Store
data "aws_ssm_parameter" "db_subnet_ids" {
  name = "/${local.name_prefix}/db_subnet_ids"

  depends_on = [aws_ssm_parameter.db_subnet_ids]
}