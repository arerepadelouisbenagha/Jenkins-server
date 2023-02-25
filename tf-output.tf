output "jenkins-ip" {
  value = [aws_eip.instance.public_ip]
}

output "website_url" {
  value = "http://${aws_eip.instance.public_ip}:8080/"
}