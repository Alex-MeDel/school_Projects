# ==========================================
# AUTHENTICATION: Cryptographic Key Pairs
# Description: Provisions the public SSH key required for secure, 
# passwordless access to the Linux-based EC2 instances.
# ==========================================

# PREREQUISITE: Generate the key pair locally before running 'terraform apply'
# Command: ssh-keygen -t rsa -b 4096 -f ~/.ssh/epic_key

# POST-DEPLOYMENT ACCESS:
# Command: ssh -i ~/.ssh/epic_key ubuntu@<management_public_ip>

resource "aws_key_pair" "epic_key" {
    key_name   = "epic-key"
    public_key = file("~/.ssh/epic_key.pub")
}
