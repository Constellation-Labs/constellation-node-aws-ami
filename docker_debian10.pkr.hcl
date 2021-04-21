locals {
  become = "no"
}

source "docker" "cl-node" {
  image  = "python:buster"
  commit = true
  pull   = true
}

build {
  sources = [
    "source.docker.cl-node"
  ]

  provisioner "shell" {
    inline = [
      "apt update",
      "apt-get install -y ansible"
    ]
  }

  provisioner "ansible-local" {
    playbook_file   = "./ansible/playbook_docker.yml"
    role_paths = [
      "ansible/roles/java8",
      "ansible/roles/fail2ban"
    ]
    extra_arguments = ["--extra-vars", "\"should_become=${local.become}\""]
  }
}
