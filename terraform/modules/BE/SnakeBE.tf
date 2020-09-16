resource "aws_launch_configuration" "snakeBE" {
  name            = var.name
  image_id        = var.ami-id
  instance_type   = var.instance-type
  security_groups = var.security-group-ids
  associate_public_ip_address = true



  user_data = <<EOF
#!/bin/bash
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo docker pull m8ivan/snekisnek:latest
sudo docker run --env NODE_ENV=production -d --network host --name snekbackend m8ivan/snekbackend:latest
EOF
}

output "testbe" {
  value = aws_launch_configuration.snakeBE.id
}