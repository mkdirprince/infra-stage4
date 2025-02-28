# create security group
resource "aws_security_group" "stage4" {
  name   = "stage4"
  vpc_id = var.vpc_id

  tags = {
    Name = "stage4"
  }
}

resource "aws_vpc_security_group_ingress_rule" "stage4" {
  security_group_id = aws_security_group.stage4.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "stage4_http" {
  security_group_id = aws_security_group.stag4.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "stage4_https" {
  security_group_id = aws_security_group.stage4.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "stage4__traefik" {
  security_group_id = aws_security_group.stage.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.stage4.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

# create ec2 instance
resource "aws_instance" "stage4_instance" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.stag4.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 16
    volume_type = "gp2"
  }

  tags = {
    Name = "stage4_instance"
  }

  # Wait for the instance to be fully available before proceeding
  provisioner "remote-exec" {
    inline = ["echo 'Server is ready!'"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key_path)
      host        = self.public_ip
    }
  }
}

resource "aws_route53_zone" "stage4_zone" {
  name = "mkdirprince.uk"

}

# Create Route53 record for the domain
resource "aws_route53_record" "domain" {
  count   = var.domain_name != "" ? 1 : 0
  zone_id = aws_route53_zone.stage4.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 300
  records = [aws_instance.devops_stage4_instance.public_ip]
}

# Create subdomains for the APIs
resource "aws_route53_record" "auth_subdomain" {
  count   = var.domain_name != "" ? 1 : 0
  zone_id = aws_route53_zone.stage4_zone.zone_id
  name    = "auth.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.stage4_instance.public_ip]
}

resource "aws_route53_record" "todos_subdomain" {
  count   = var.domain_name != "" ? 1 : 0
  zone_id = aws_route53_zone.tage4_zone.zone_id
  name    = "todos.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.stage4_instance.public_ip]
}

resource "aws_route53_record" "users_subdomain" {
  count   = var.domain_name != "" ? 1 : 0
  zone_id = aws_route53_zone.stage4_zone.zone_id
  name    = "users.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.stage4_instance.public_ip]
}

# Generate Ansible inventory file
resource "local_file" "ansible_inventory" {
  content = templatefile("../ansible/templates/inventory.tmpl", {
    ip_address   = aws_instance.stage4_instance.public_ip
    ssh_user     = "ubuntu"
    ssh_key_file = var.key_path
    domain_name  = var.domain_name
    admin_email  = var.admin_email
  })
  filename = "../ansible/inventory/hosts.yml"

  depends_on = [aws_instance.stage4_instance, null_resource.create_ansible_dirs]
}

# Generate Ansible variables file
resource "local_file" "ansible_vars" {
  content = templatefile("../ansible/templates/vars.tmpl", {
    domain_name  = var.domain_name
    admin_email  = var.admin_email
    git_repo_url = var.git_repo_url
    git_branch   = var.git_branch
  })
  filename = "../ansible/vars/main.yml"

  depends_on = [aws_instance.stage4_instance, null_resource.create_ansible_dirs]
}

resource "null_resource" "create_ansible_dirs" {
  provisioner "local-exec" {
    command = <<EOT
      mkdir -p ../ansible/inventory
      mkdir -p ../ansible/vars
    EOT
  }
}


# Run Ansible playbook
resource "null_resource" "ansible_provisioner" {
  triggers = {
    instance_id = aws_instance.stage4_instance.id
  }

  provisioner "local-exec" {
    command = "cd ../ansible && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory/hosts.yml playbook.yml -vvv"
  }

  depends_on = [local_file.ansible_inventory, local_file.ansible_vars]
}
