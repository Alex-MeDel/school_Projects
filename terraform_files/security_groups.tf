# ==========================================
# SECURITY GROUPS: Network Isolation & Access Control
# These section will act as stateful firewalls, controlling who can talk to whom
# ==========================================

# ------------------------------------------
# 1. Public "Management" Zone
# ------------------------------------------
resource "aws_security_group" "management_sg" {
    name   = "management-sg"
    description = "Security rules for Management Zone"
    vpc_id = aws_vpc.main_vpc.id

    # INGRESS: Who to allow to connect via SSH
    ingress {
        from_port   = 22 # 22 is standard SSH port
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # <-- Bootstrapping code (Change to one of other options after boostrapping phase)
    #    cidr_blocks = ["10.0.0.0/16"] # Via Client VPN only
    #    cidr_blocks = ["IP_ADDRESS/32"] # Via IP whitelist only
    }

    # INGRESS: UDP 1194 (OpenVPN)
    ingress {
        from_port   = 1194
        to_port     = 1194
        protocol    = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    }    

    # EGRESS: Talking to open internet essentially
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"] # BOOTSTRAPPING - Comment out when finished boostrapping
    #    cidr_blocks = ["127.0.0.1/32"] # Block all outbound, can uncomment to block internet
    }

    # EGRESS: DB traffic for postgres
    egress {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }    
}

# ------------------------------------------
# 2. Private "Internal" Zone
# ------------------------------------------
resource "aws_security_group" "internal_sg" {
    name   = "internal-sg"
    description = "Security rules for the internal zone"
    vpc_id = aws_vpc.main_vpc.id

    # TEMPORARY DEBUGGING: RDP ingress rule for debugging
    ingress {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # TEMPORARY DEBUGGING: SSH ingress rule for Internal SG - DELETE OR COMMENT LATER!!!
    ingress {
        from_port   = 22 
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # DB traffic rule, for postgres - only from management_sg <- I think
    ingress {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = ["10.0.2.0/24"]
    }

    # Web traffic rule, for IIS - only from management_sg
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["10.0.2.0/24"] # Allow only the Management Subnet
    }

    # EGRESS: Allow DNS resolution via Route 53 (UDP port 53)
    # Required for internal hostnames to resolve post-lockdown
    egress {
        from_port   = 53
        to_port     = 53
        protocol    = "udp"
        cidr_blocks = ["10.0.0.0/16"] # VPC-wide, I think
    }


    # EGRESS: lockdown - Block all outbound internet traffic
    # Necessary to be open during boostrapping phase for downloads
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"] # Bootstrapping code 
    #    cidr_blocks = ["127.0.0.1/32"] # No Internet 
    }
}

