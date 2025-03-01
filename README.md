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

You'll need to download and have the following:

- Terraform
- Ansible
- Cloud Credentials - Valid access keys for AWS, GCP, or Azure

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
