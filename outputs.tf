output "ec2-public-ip" {
  value = module.my-app-webserver.ec2-details.public_ip
}