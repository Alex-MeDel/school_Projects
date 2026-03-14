# ==========================================
# NETWORKING CORE: VPC, Subnets & Routing
# Description: Defines the network boundary, isolated subnets, 
# and route tables for the architecture.
# ==========================================

# Foundational Virtual Private Cloud (VPC)
resource "aws_vpc" "main_vpc" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    tags = { Name = "The-VPC" }
}

# ------------------------------------------
# SUBNET 1: Private Subnet
# ------------------------------------------
# Private subnet that hauses the "honey" assets 
resource "aws_subnet" "internal_zone" {
    vpc_id     = aws_vpc.main_vpc.id
    cidr_block = "10.0.1.0/24"
    tags       = { Name = "Internal-Zone" }
}

# ------------------------------------------
# SUBNET 2: Public Subnet
# ------------------------------------------
# Public-facing management subnet hosting the ELK stack
resource "aws_subnet" "management_zone" {
    vpc_id     = aws_vpc.main_vpc.id
    cidr_block = "10.0.2.0/24"
    tags       = { Name = "Management-Zone" }
}


# ==========================================
# INTERNET GATEWAY & ROUTING
# Description: Provides external routing for bootstrap package 
# retrieval and whitelisted administrator access.
# ==========================================

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags   = { Name = "IGW" }
}

resource "aws_route_table" "management_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "Management-Public-RT" }
}

resource "aws_route_table_association" "management_rta" {
  subnet_id      = aws_subnet.management_zone.id
  route_table_id = aws_route_table.management_rt.id
}

# might remove post boostrap, or might just handle it in security_groups.tf, idk
resource "aws_route_table_association" "internal_rta" {
  subnet_id      = aws_subnet.internal_zone.id
  route_table_id = aws_route_table.management_rt.id
}