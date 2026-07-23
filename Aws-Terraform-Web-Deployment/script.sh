#!/bin/bash
sudo apt update -y
sudo apt install apache2 -y
sudo systemctl start apache2
sudo systemctl enable apache2
cd /var/www/html
sudo rm -rf *
git clone https://github.com/shravnibhadale/Aws-Terraform-Web-Deployment.git .
