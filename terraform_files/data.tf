# ==========================================
# DATA SOURCES: Dynamic AMI Retrieval
# Description: Queries the AWS API to dynamically fetch the latest 
# official Amazon Machine Images (AMIs) for the instances.
# This prevents the use of hardcoded, deprecated OS versions.
# ==========================================

# This is to get rid of hardcoded AMI IDs, this just retreives the latests AMI IDs from each OS

# ------------------------------------------
# UBUNTU LINUX AMI: Ubuntu 22.04 LTS (Jammy Jellyfish)
# ------------------------------------------

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's official AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ------------------------------------------
# RHEL LINUX AMI: RHEL
# ------------------------------------------
data "aws_ami" "RHEL" {
  most_recent = true
  owners      = ["301981759614"] # Red Hat's official AWS account ID

  filter {
    name   = "name"
    values = ["RHEL-9.*_HVM-*-x86_64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ------------------------------------------
# WINDOWS 2022 AMI: Windows Server 2022
# ------------------------------------------

data "aws_ami" "windows_2022" {
  most_recent = true
  owners      = ["801119661308"] # Amazon's official Windows AMI account ID

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"] 
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ------------------------------------------
# WINDOWS 2019 AMI: Windows Server 2019
# ------------------------------------------

data "aws_ami" "windows_2019" {
  most_recent = true
  owners      = ["801119661308"] # Amazon's official Windows AMI account ID

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"] 
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}