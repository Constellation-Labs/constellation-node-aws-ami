variable "region" {
  type    = string
  default = "us-west-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  become    = "yes"
}

source "amazon-ebs" "cl-node" {
  ami_name         = "constellation-node-${local.timestamp}"
  instance_type    = "${var.instance_type}"
  region           = "${var.region}"
  force_deregister = true

  source_ami_filter {
    filters = {
      name                = "*debian-10-amd64*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners = [
      "903794441882"
    ]
  }

  ssh_username = "admin"
}

build {
  sources = [
    "source.amazon-ebs.cl-node"
  ]

  provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo apt-get install -y ansible"
    ]
  }

  provisioner "ansible-local" {
    playbook_file   = "./ansible/playbook_ec2.yml"
    role_paths = [
      "ansible/roles/java8",
      "ansible/roles/fail2ban"
    ]
    extra_arguments = ["--extra-vars", "\"should_become=${local.become}\""]
  }
}
