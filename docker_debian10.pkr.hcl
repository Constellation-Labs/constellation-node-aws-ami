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
    playbook_file   = "./ansible/playbook_java8.yml"
    extra_arguments = ["--extra-vars", "\"should_become=${local.become}\""]
  }
}
