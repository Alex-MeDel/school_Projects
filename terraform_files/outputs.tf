# ==========================================
# OUTPUTS: Infrastructure Endpoints & Metadata
# Description: Displays crucial connection strings and dynamically 
# fetched AMI IDs immediately after a successful 'terraform apply'.
# ==========================================

# The public IPv4 address for "The Brain" (Management Server)
output "management_public_ip" {
  value       = aws_instance.management_linux.public_ip
  description = "SSH: ssh -i ~/.ssh/epic_key ubuntu@<this IP>"
}


# Debugging/Verification: Displays the dynamically selected Ubuntu AMI
output "ubuntu_ami_used" {
  value = data.aws_ami.ubuntu.id
  description = "The specific Ubuntu AMI ID used for management linux"
}

# Debugging/Verification: Displays the dynamically selected Ubuntu AMI
output "RHEL_ami_used" {
  value = data.aws_ami.RHEL.id
  description = "The specific RHEL AMI ID used for database server"
}

# Debugging/Verification: Displays the dynamically selected Windows Server 2022
output "windows2022_ami_used" {
  value = data.aws_ami.windows_2022.id 
  description = "The specific Windows Server 2022 AMI"
}

# Debugging/Verification: Displays the dynamically selected Windows Server 2019
output "windows2019_ami_used" {
  value = data.aws_ami.windows_2019.id 
  description = "The specific Windows Server 2019 AMI"
}

