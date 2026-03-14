# AWS Secure Infrastructure — Terraform

A fully automated, IaaS cloud environment provisioned on AWS using Terraform. Designed for a secure migration scenario, the project deploys a multi-server, multi-OS environment across isolated network zones with automated bootstrapping, private DNS, VPN, and DNS-level domain filtering.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                     AWS VPC (10.0.0.0/16)               │
│                                                         │
│  ┌─────────────────────┐   ┌─────────────────────────┐  │
│  │  Management Zone    │   │    Internal Zone        │  │
│  │   (10.0.2.0/24)     │   │    (10.0.1.0/24)        │  │
│  │  PUBLIC SUBNET      │   │    PRIVATE SUBNET       │  │
│  │                     │   │                         │  │
│  │  ┌───────────────┐  │   │  ┌───────────────────┐  │  │
│  │  │ Ubuntu 22.04  │  │   │  │   RHEL 9 (DB)     │  │  │
│  │  │ Jumpbox + VPN │  │   │  │   PostgreSQL      │  │  │
│  │  └───────────────┘  │   │  └───────────────────┘  │  │
│  └─────────────────────┘   │  ┌───────────────────┐  │  │
│            │               │  │  Windows 2022     │  │  │
│            │ OpenVPN       │  │  IIS App Server   │  │  │
│            │               │  └───────────────────┘  │  │
│       Internet GW          │  ┌───────────────────┐  │  │
│            │               │  │  Windows 2019     │  │  │
│            │               │  │  IIS App Server   │  │  │
└────────────┼───────────────┴──┴───────────────────┴──┘  
             │                                            
           Internet
```

---

## Features

- **Multi-OS environment** — Ubuntu 22.04, RHEL 9, Windows Server 2022, and Windows Server 2019
- **Network isolation** — Public management subnet and private internal subnet with separate security groups
- **OpenVPN server** — Certificate-based VPN with a full PKI (CA, server cert, DH params, client cert) auto-generated on boot
- **Private DNS** — Route 53 private hosted zone (`main.internal`) with A-records for all instances
- **DHCP** — AWS-native DHCP options set tied to the private domain
- **NTP** — All instances configured to use the Amazon Time Sync Service (`169.254.169.123`)
- **PostgreSQL database** — Auto-initialized on RHEL with a default database and admin user
- **IIS web server** — Installed on both Windows instances with a custom identity page
- **DNS firewall** — Route 53 Resolver Firewall blocks a configurable list of unauthorized domains
- **S3 bootstrap pattern** — Scripts stored in a randomized S3 bucket and pulled down at boot, bypassing `user_data` size limits
- **Dynamic AMI lookup** — No hardcoded AMI IDs; always pulls the latest official images from Canonical, Red Hat, and Amazon

---

## Project Structure

```
.
├── main.tf                  # Provider config
├── variables.tf             # Input variables
├── vpc.tf                   # VPC, subnets, route tables, internet gateway
├── instances.tf             # EC2 instance definitions (all 4 servers)
├── security_groups.tf       # Security groups + Route 53 DNS Firewall rules
├── dns.tf                   # Private hosted zone, A-records, DHCP options
├── data.tf                  # Dynamic AMI data sources
├── s3.tf                    # Bootstrap S3 bucket and script uploads
├── keys.tf                  # SSH key pair
├── outputs.tf               # Post-deploy connection info and AMI IDs
└── scripts/
    ├── ubuntu_bootstrap.sh      # Ubuntu: OpenVPN PKI, NTP, domain lockdown
    ├── RHEL_bootstrap.sh        # RHEL: PostgreSQL setup, NTP, domain lockdown
    └── windows_bootstrap.ps1    # Windows: IIS, NTP, Defender policies, domain lockdown
```

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- AWS CLI configured with valid credentials (or an active Academy lab session)
- An SSH key pair at `~/.ssh/epic_key` and `~/.ssh/epic_key.pub`

Generate the key pair if you don't have one:
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/epic_key
```

---

## Deployment

**1. Initialize Terraform**
```bash
terraform init
```

**2. Preview the plan**
```bash
terraform plan
```

**3. Deploy**
```bash
terraform apply
```

After a successful apply, Terraform will output the management server's public IP and the AMI IDs that were selected.

**4. Connect to the management server**
```bash
ssh -i ~/.ssh/epic_key ubuntu@<management_public_ip>
```

**5. Tear down**
```bash
terraform destroy
```

---

## Post-Bootstrap Hardening

The following items are intentionally left open during the bootstrap phase and **should be locked down before treating this environment as production-ready:**

| Resource | Current State | Recommended Change |
|---|---|---|
| `management_sg` SSH ingress | `0.0.0.0/0` | Restrict to your IP (`x.x.x.x/32`) or VPN only |
| `internal_sg` SSH ingress | `0.0.0.0/0` | Restrict to `10.0.2.0/24` (management zone only) |
| `internal_sg` RDP ingress | `0.0.0.0/0` | Restrict to `10.0.2.0/24` (management zone only) |
| `internal_sg` egress | `0.0.0.0/0` | Lock down to VPC CIDR + specific ports after bootstrapping |
| `associate_public_ip_address` on internal instances | `true` | Set to `false` once bootstrapping is complete |

---

## Security Controls

| Requirement | Implementation |
|---|---|
| Locks down unauthorized domains | Route 53 Resolver Firewall + `/etc/hosts` fallback on all instances |
| Locks down unauthorized IP ranges | Security group ingress/egress rules |
| Locks down unauthorized port ranges | Security group rules per subnet zone |
| VPN for confidentiality | OpenVPN with full PKI auto-generated on Ubuntu server |
| Certificate-based privacy | EasyRSA CA, server cert, client cert, DH params |
| DNS (trusted) | Route 53 private hosted zone + AmazonProvidedDNS |
| DHCP | `aws_vpc_dhcp_options` associated with the VPC |
| NTP (trusted servers) | Amazon Time Sync Service on all OS types |
| Database | PostgreSQL 15 on RHEL 9 |
| 2x Windows + 2x Linux (multi-flavor) | Windows 2019, Windows 2022, Ubuntu 22.04, RHEL 9 |

---

## Outputs

| Output | Description |
|---|---|
| `management_public_ip` | Public IP of the Ubuntu management/VPN server |
| `ubuntu_ami_used` | AMI ID selected for Ubuntu |
| `RHEL_ami_used` | AMI ID selected for RHEL |
| `windows2022_ami_used` | AMI ID selected for Windows Server 2022 |
| `windows2019_ami_used` | AMI ID selected for Windows Server 2019 |

---

## Notes

- The `LabInstanceProfile` IAM role is hardcoded due to AWS Academy Learner Lab restrictions. In a real environment, replace this with a purpose-scoped IAM role.
- The S3 bucket uses a random suffix (`random_id`) to ensure global uniqueness across deployments.
- Bootstrap logs are written to `/var/log/bootstrap.log` on Linux instances and `C:\bootstrap_log.txt` on Windows for post-deploy verification.

(This README.md file was generated by Claude.AI and checked for errors)