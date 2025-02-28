# Infrastructure Automation with Terraform and Ansible

## Overview

This project streamlines cloud environment setup by combining Infrastructure as Code (IaC) and Configuration Management techniques. Using Terraform for provisioning and Ansible for configuration, it establishes a complete DevOps workflow that creates servers, sets up network security, builds dynamic inventories, and deploys containerized applications.

```yaml
├── ansible
│   ├── inventory
│   │   └── hosts.yml
│   ├── playbook.yml
│   ├── roles
│   │   ├── dependencies
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   └── deployment
│   │       └── tasks
│   │           └── main.yml
│   ├── templates
│   │   ├── inventory.tmpl
│   │   └── vars.tmpl
│   └── vars
│       └── main.yml
├── terraform
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── terraform.tfvars
│   └── variables.tf
└── README.md
```

## Prerequisites

You'll need:

- Terraform - Download from terraform.io
- Ansible - Follow installation guide at docs.ansible.com
- Cloud Credentials - Valid access keys for AWS, GCP, or Azure
- SSH Keys - Generated pair for secure server access

---

## Implementation Guide

### Step 1: Provision Infrastructure with Terraform

1. Navigate to the Infrastructure directory:
   ```bash
   cd terraform
   ```
2. configure terraform.tfvars to set your specific configuration values for your instance:
   ```bash
    aws_region        = "us-east-1"
    vpc_cidr          = "10.0.0.0/16"
    instance_type     = "t2.micro"
    key_name          = "your-key-name"
    domain_name       = "your-domain.com"
    environment       = "production"
   ```
3. Initialize Terraform
   ```bash
   terraform init
   ```
4. Review the execution plan:
   ```bash
   terraform plan
   ```
5. Apply the configuration to provision resources:
   ```bash
   terraform apply --auto-approve
   ```

### Step 2: Configure Servers with Ansible

1. Navigate to the ansible directory:
   ```bash
   cd ../ansible
   ```
2. Run the Ansible playbook:
   `bash
ansible-playbook -i inventory/hosts.yml playbook.yml
`
   The Ansible automation folder plays two roles:
3. Dependency Role
   - Installs and configures:
     - Docker
     - Docker Compose
     - Other system dependencies specified
4. Deployment Role
   - runs deployment:
     - Clones the application repository
     - Configures environment variables
     - Sets up Docker Compose with the application
     - Configures Traefik as a reverse proxy with automatic SSL/TLS

### Reverse Proxy:

Reverse Proxy and SSL/TLS is handles by Traefik
