# Output Networking Values
# VPC ID
output "vpc_id" {
  value = aws_vpc.main.id
}

# Public Subnet IDs
output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

# Public Subnets CIDR
output "public_subnet_cidr" {
  value = aws_subnet.public[*].cidr_block
}

# App Subnet IDs
output "app_subnet_ids" {
  value = aws_subnet.app_private[*].id
}

# App Subnets CIDR
output "app_subnet_cidr" {
  value = aws_subnet.app_private[*].cidr_block
}

# DB Subnet IDs
output "db_subnet_ids" {
  value = aws_subnet.db_private[*].id
}

# DB Subnets CIDR
output "db_subnet_cidr" {
  value = aws_subnet.db_private[*].cidr_block
}

# EIP
output "nat_eip" {
  value = aws_eip.nat_eip.public_ip
}

# NAT Gateway ID
output "nat_id" {
  value = aws_nat_gateway.nat.id
}

# Public Route Table ID
output "public_rtb_id" {
  value = aws_route_table.public.id
}

# Private Route Table ID
output "private_rtb_id" {
  value = aws_route_table.private.id
}
