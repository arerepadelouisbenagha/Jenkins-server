output "jenkins-ip" {
  value = [aws_instance.jenkins-instance.public_ip]
}

output "website_url" {
  value = "http://${aws_instance.jenkins-instance.public_ip}:8080/"
}