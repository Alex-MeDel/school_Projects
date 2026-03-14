# ==========================================
# INTERNAL DNS: Route 53 Private Hosted Zone
# Description: Establishes a private namespace to allow instances 
# to communicate via FQDNs rather than static IP addresses.
# ==========================================

# Creates a private directory called "main.internal" only visible inside this VPC
resource "aws_route53_zone" "private" {
    name = "main.internal"
    vpc { vpc_id = aws_vpc.main_vpc.id } # This tells AWS to create a private DNS Zone (Domain that doesnt exist in public internet)
}

# ------------------------------------------
# DNS A-RECORDS (IPv4 Address Mapping)
# ------------------------------------------

# Assigns the name "win2019.main.internal" to the windows 2019 
resource "aws_route53_record" "win2019" {
    zone_id = aws_route53_zone.private.zone_id 
    name    = "win2019.main.internal" # DNS entry 
    type    = "A" # type "A" - this stands for "Address", this is a standard way to map a name to IPv4 address
    ttl     = "300" # Time To Live - this tells other computers to remember the address has 5 minutes before asking the phonebook for an update
    records = [aws_instance.win_2019.private_ip] 
}

# Assigns the name "win2022.main.internal" to the windows 2022
resource "aws_route53_record" "win2022" {
    zone_id = aws_route53_zone.private.zone_id 
    name    = "win2022.main.internal" # DNS entry 
    type    = "A" # type "A" - this stands for "Address", this is a standard way to map a name to IPv4 address
    ttl     = "300" # Time To Live - this tells other computers to remember the address has 5 minutes before asking the phonebook for an update
    records = [aws_instance.win_2022.private_ip] 
}

# Assigns the name "ubuntu.main.internal" to the ubuntu Server Linux
resource "aws_route53_record" "ubuntu" {
    zone_id = aws_route53_zone.private.zone_id 
    name    = "ubuntu.main.internal" # DNS entry 
    type    = "A" # type "A" - this stands for "Address", this is a standard way to map a name to IPv4 address
    ttl     = "300" # Time To Live - this tells other computers to remember the address has 5 minutes before asking the phonebook for an update
    records = [aws_instance.management_linux.private_ip] 
}

# Assigns the name "RHEL.main.internal" to the RHEL Server Linux
resource "aws_route53_record" "RHEL" {
    zone_id = aws_route53_zone.private.zone_id 
    name    = "RHEL.main.internal" # DNS entry 
    type    = "A" # type "A" - this stands for "Address", this is a standard way to map a name to IPv4 address
    ttl     = "300" # Time To Live - this tells other computers to remember the address has 5 minutes before asking the phonebook for an update
    records = [aws_instance.database_server.private_ip] 
}

# ==========================================
# DHCP OPTION SET
# ==========================================

# Defines the DHCP parameters handed out to instances
resource "aws_vpc_dhcp_options" "main_dhcp" {
  domain_name         = "main.internal"
  domain_name_servers = ["AmazonProvidedDNS"] # Uses AWS's highly available DNS
  tags                = { Name = "Main-DHCP-Options" }
}

# Associates the DHCP options with the specific VPC
resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.main_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.main_dhcp.id
}

