output "aws-public-ip" {
  value = aws_instance.myapp-server.public_ip
}