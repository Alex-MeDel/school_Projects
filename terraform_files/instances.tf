# ==========================================
# COMPUTE RESOURCES: Virtual Instances & Decoys
# Description: Creates all 4 instances
# ==========================================

# ------------------------------------------
# 1. Ubuntu Linux (Public Subnet) 
# OS: Ubuntu 22.04 LTS | Role: Management Jumpbox & VPN Server
# ------------------------------------------

resource "aws_instance" "management_linux" {
    ami                    = data.aws_ami.ubuntu.id # This is set in the data.tf, dynamic AMI IDs
    instance_type          = "t3.medium" # Instance type from AWS, 
    subnet_id              = aws_subnet.management_zone.id # Subnets created in vpc.tf
    vpc_security_group_ids = [aws_security_group.management_sg.id] # This is from security_groups.tf
    key_name               = aws_key_pair.epic_key.key_name  # This is part of SSH config
    associate_public_ip_address = true   # This line will give a public IP address for bootstraping
    iam_instance_profile = "LabInstanceProfile" # hard coded due to Learner Lab limitations
    tags                   = { Name = "ubuntu_linux" } # This is for billing info

    # CONFIGURE EVERYTHING ON STARTUP!!!
    # Passes the dynamic S3 bucket ID to the bash script
    user_data = templatefile("${path.module}/scripts/ubuntu_bootstrap.sh", {
      bucket_name = aws_s3_bucket.bootstrap.id # This is configured in s3.tf
    })
}


# ------------------------------------------
# 2. RHEL
# OS: RHEL | Role: Database Server
# ------------------------------------------

resource "aws_instance" "database_server" {
    ami                    = data.aws_ami.RHEL.id # This is set in the data.tf, dynamic AMI IDs 
    instance_type          = "t3.medium"
    subnet_id              = aws_subnet.internal_zone.id
    vpc_security_group_ids = [aws_security_group.internal_sg.id]
    key_name               = aws_key_pair.epic_key.key_name  # This is part of SSH config
    associate_public_ip_address = true   # internet while bootstraping 
    iam_instance_profile = "LabInstanceProfile"
    tags                   = { Name = "RHEL-DataBase" }

    # AUTOMATE EVERYTHING!!! 
    # Executes local bash script to provision DICOM services and Filebeat
    user_data = file("${path.module}/scripts/RHEL_bootstrap.sh")
}

# ------------------------------------------
# 3. Windows 2022
# OS: Windows 2022 | Role: Internal App Server 1
# ------------------------------------------

resource "aws_instance" "win_2022" {
    ami                    = data.aws_ami.windows_2022.id # Automatic AMI IDs thing
    instance_type          = "t3.medium"
    subnet_id              = aws_subnet.internal_zone.id 
    vpc_security_group_ids = [aws_security_group.internal_sg.id] 
    key_name               = aws_key_pair.epic_key.key_name  # This is part of SSH config
    associate_public_ip_address = true   # internet while bootstraping 
    iam_instance_profile = "LabInstanceProfile"
    tags                   = { Name = "Win-2022" } 

    user_data = <<-EOF
        <powershell>
        $bucket = "${aws_s3_bucket.bootstrap.id}"
        $dest   = "C:\windows_bootstrap.ps1"

        # Force TLS 1.2 for AWS S3 compatibility (Absolutely necesary or 403)
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        # Download and silently install the AWS CLI
        Invoke-WebRequest -Uri "https://awscli.amazonaws.com/AWSCLIV2.msi" -OutFile "C:\AWSCLIV2.msi"
        Start-Process msiexec.exe -Wait -ArgumentList '/i C:\AWSCLIV2.msi /qn'
        
        # Use the AWS CLI to download the bootstrap script. 
        # This automatically signs the request using your LabInstanceProfile!
        & "C:\Program Files\Amazon\AWSCLIV2\aws.exe" s3 cp s3://$bucket/windows_bootstrap.ps1 $dest
        
        # Execute the downloaded script
        PowerShell.exe -ExecutionPolicy Bypass -File $dest
        </powershell>
        EOF
}

# ------------------------------------------
# 4. Windows 2019
# OS: Windows 2019 | Role: Internal App Server 2
# ------------------------------------------

resource "aws_instance" "win_2019" {
    ami                    = data.aws_ami.windows_2019.id # Automatic AMI IDs thing
    instance_type          = "t3.medium"
    subnet_id              = aws_subnet.internal_zone.id 
    vpc_security_group_ids = [aws_security_group.internal_sg.id] 
    key_name               = aws_key_pair.epic_key.key_name  # This is part of SSH config
    associate_public_ip_address = true   # internet while bootstraping 
    iam_instance_profile = "LabInstanceProfile"
    tags                   = { Name = "Win-2019" } 

    user_data = <<-EOF
        <powershell>
        $bucket = "${aws_s3_bucket.bootstrap.id}"
        $dest   = "C:\windows_bootstrap.ps1"

        # Force TLS 1.2 for AWS S3 compatibility (Absolutely necesary or 403)
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        # Download and silently install the AWS CLI
        Invoke-WebRequest -Uri "https://awscli.amazonaws.com/AWSCLIV2.msi" -OutFile "C:\AWSCLIV2.msi"
        Start-Process msiexec.exe -Wait -ArgumentList '/i C:\AWSCLIV2.msi /qn'
        
        # Use the AWS CLI to download the bootstrap script. 
        # This automatically signs the request using your LabInstanceProfile!
        & "C:\Program Files\Amazon\AWSCLIV2\aws.exe" s3 cp s3://$bucket/windows_bootstrap.ps1 $dest
        
        # Execute the downloaded script
        PowerShell.exe -ExecutionPolicy Bypass -File $dest
        </powershell>
        EOF
}

