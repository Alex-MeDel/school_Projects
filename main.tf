# Goal of this, is to redeploy the entire hospital environment automatically if an instance crashes or needs to be reset
# Hybrid Architecture (Containers + VMs) + VPC, Subnets, Security Groups, compute resources, etc.
# Full Disclosure, I used A LOT of Google and Google Gemini for the creation of this file
# First time using terraform, I was clueless at the beggining. 

# Hospital Honeypot Master Configuration
# Purpose: Automated deployment of an isolated, dual-zone medical security sandbox 
# Compliance: Strict outbound blocking to adhere to AWS Terms of Service 

provider "aws" {
  region = "us-east-1"
}

# ==========================================
# STEP 1: NETWORK FOUNDATION 
# ==========================================

resource "aws_vpc" "hospital_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "Hospital-Honeypot-VPC" }
}

resource "aws_subnet" "clinical_zone" {
  vpc_id     = aws_vpc.hospital_vpc.id
  cidr_block = "10.0.1.0/24"
  tags       = { Name = "Clinical-Zone" }
}

resource "aws_subnet" "brain_zone" {
  vpc_id     = aws_vpc.hospital_vpc.id
  cidr_block = "10.0.2.0/24"
  tags       = { Name = "The-Brain-Zone" }
}

# ==========================================
# STEP 2: SECURITY GROUPS (Isolation) 
# ==========================================

# Brain SG: Protects the ELK Stack 
resource "aws_security_group" "brain_sg" {
  name   = "brain-sg"
  vpc_id = aws_vpc.hospital_vpc.id

  ingress {
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"] # Allow Beats from Clinical Zone [cite: 40]
  }

  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Access via Client VPN [cite: 13]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["127.0.0.1/32"] # Block all outbound [cite: 39]
  }
}

# Clinical SG: Protects the Honeypot Assets [cite: 10]
resource "aws_security_group" "clinical_sg" {
  name   = "clinical-sg"
  vpc_id = aws_vpc.hospital_vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/24"] # Allow Validation Script "Knocks" [cite: 51, 85]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/24"] # Allow log shipping to Brain [cite: 40]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["127.0.0.1/32"] # Compliance: No Internet [cite: 4, 39]
  }
}

# ==========================================
# STEP 3: COMPUTE RESOURCES [cite: 15, 16]
# ==========================================

# The Brain (Ubuntu 22.04 + ELK Docker) 
resource "aws_instance" "the_brain" {
  ami                    = "ami-0c7217cdde317cfec" 
  instance_type          = "t3.large"
  subnet_id              = aws_subnet.brain_zone.id
  vpc_security_group_ids = [aws_security_group.brain_sg.id]
  private_ip             = "10.0.2.10"
  tags                   = { Name = "The-Brain-ELK" }
}

# Medical Workstation (Windows 7/2012 Legacy) 
resource "aws_instance" "win7_workstation" {
  ami                    = "ami-032599769356f916d" 
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.clinical_zone.id
  vpc_security_group_ids = [aws_security_group.clinical_sg.id]
  tags                   = { Name = "Win7-Clinical-Workstation" }
}

# Imaging Server (Ubuntu + DICOM Sim) 
resource "aws_instance" "imaging_server" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.clinical_zone.id
  vpc_security_group_ids = [aws_security_group.clinical_sg.id]
  private_ip             = "10.0.1.20"
  tags                   = { Name = "Imaging-Server-PACS" }
}

# IoT Gateway (Ubuntu + Conpot Docker)
resource "aws_instance" "iot_gateway" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.clinical_zone.id
  vpc_security_group_ids = [aws_security_group.clinical_sg.id]
  private_ip             = "10.0.1.30"
  tags                   = { Name = "IoT-Gateway-Conpot" }
}

# ==========================================
# STEP 4: PRIVATE DNS (Route 53) 
# ==========================================

resource "aws_route53_zone" "private" {
  name = "hospital.internal"
  vpc { vpc_id = aws_vpc.hospital_vpc.id }
}

resource "aws_route53_record" "pacs" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "pacs.hospital.internal"
  type    = "A"
  ttl     = "300"
  records = ["10.0.1.20"]
}

resource "aws_route53_record" "iot" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "iot-gateway.hospital.internal"
  type    = "A"
  ttl     = "300"
  records = ["10.0.1.30"]
}