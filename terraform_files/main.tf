# Just a little project for a class
# Here are the requirements for this assigment: 
# For this assignment you are to create an implementation and secure migration plan.  Architect and implement the technical components to this specification. Leverage cloud capabilities to accomplish this task. Ensure to include your logic and reasoning for your approach:

# Pre-migration

# (Initial briefing) Write a Paper that briefs your initial plan to meet these requirements:

# A. Hosted on AWS Using an IaaS Environment) 
# B. A routed and switched environment that
#   1. Locks down unauthorized domains
#   2. Locks down unauthorized IP Ranges
#   3. Locks down unauthorized port ranges
#   4. Locks down unauthorized programs
#   5. Allows for third party agreements
#   6. Uses VLANS for management
#   7. Uses VPNs as appropriate for confidentiality
# C. 2 x Windows 2019/2022 and 2 x Linux servers (must contain 2 flavors or more) and must contain:
#   1. DNS (trusted DNS or secure DNS)
#   2. DHCP (used to assign IP addresses to devices)
#   3. NTP (trusted servers)
#   4. A database (SQL or Oracle)
#   5. Certificatesbased privacy (minimum)
# D. How will you Securely migrate on premises data to the cloud environment that you have created.

provider "aws" {
    region = var.aws_region
}