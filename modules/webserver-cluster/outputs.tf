output "instance_public_ip" {
  description = "Public IP of the Divot webserver instance"
  value = aws_instance.webserver.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the Divot webserver instance"
  value = aws_instance.webserver.public_dns
}