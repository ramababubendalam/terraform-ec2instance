resource "aws_instance" "this" {
  ami                  = var.ami
  instance_type        = var.instance_type

  user_data                   = var.user_data
  user_data_base64            = var.user_data_base64

  availability_zone      = var.availability_zone
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids

  key_name             = var.key_name
  monitoring           = var.monitoring
  iam_instance_profile = var.iam_instance_profile



  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
      encrypted             = lookup(root_block_device.value, "encrypted", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", null)
      throughput            = lookup(root_block_device.value, "throughput", null)
      tags                  = lookup(root_block_device.value, "tags", null)
    }
  }

  tags        = merge({ "Name" = var.name }, var.tags)

  provisioner "file" {
    source      = "configFiles/"
    destination = "/tmp"

  }

  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait",
      "sudo git clone https://github.com/lend-invest/echo-service",
      "sudo cp -r /tmp/Dockerfile ./echo-service/",
      "sudo cp -r /tmp/docker-compose.yml .",
      "sudo docker-compose build",
      "sudo minikube image load echo-service:latest",
      "sudo kubectl apply -f /tmp/deployment.yml",
      "sudo kubectl apply -f /tmp/service.yml"
    ]
  }

  connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.ssh_key_file_location)
      host        = self.public_ip
  }


}



