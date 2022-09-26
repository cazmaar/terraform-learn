#!/bin/bash
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo usermod -G docker ec2-user
docker run -p 8080:80 nginx