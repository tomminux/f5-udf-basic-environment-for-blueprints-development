#!/bin/bash

## ============================================================================
##
## 2.infra-server-posstReboot.sh Init Script
##
## Author:  Paolo Tomminux Arcagni - F5
## Date:    November 2020
## Version: 1.0
##
## This script can be used to install needed software for the a tipical UDF
## environemnt like:
##  - Ansible
##  - dnsmasq
##  - CodeServer
##
## Execute this script as "ubuntu" user on infra-server after the reboot
## executed by the infra-server.sh initialization script
##
## ============================================================================

## ..:: Installing needed software ::..
## ----------------------------------------------------------------------------

sudo apt install -y apt-transport-https ca-certificates curl software-properties-common ansible dnsmasq

## ..:: Docker Community Edition installation ::..
## ----------------------------------------------------------------------------

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
sudo apt install -y docker-ce
sudo usermod -aG docker ubuntu

## ..:: CodeServer Installation and Initialization ::..
## ----------------------------------------------------------------------------

mkdir ~/.config
sudo docker run --restart unless-stopped -d --name f5CodeServer -p 10.1.20.100:8080:8080 -v "$HOME/.config:/home/coder/.config" -v "$HOME:/home/coder/project" -u "$(id -u):$(id -g)" -e "DOCKER_USER=$USER" -e PASSWORD="Default1234!" codercom/code-server:latest

## ..:: DNSMASQ Installation and Initialization ::..
## ----------------------------------------------------------------------------

sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
sudo sh -c 'echo "10.1.1.4 infra-server.f5-udf.com infra-server" >> /etc/hosts'
sudo rm /etc/resolv.conf

sudo sh -c 'cat <<EOF > /etc/resolv.conf
search f5-udf.com
nameserver 10.1.1.4
nameserver 10.1.255.254
nameserver 8.8.8.8
EOF'

sudo systemctl enable dnsmasq
sudo systemctl restart dnsmasq

## ..:: Aliases Configuration ::..
## ----------------------------------------------------------------------------

cat <<EOF >> /home/ubuntu/.bashrc
alias ka='kubectl apply -f'
alias kd='kubectl delete -f'
alias kg='kubectl get'
alias kgp='kubectl get pods -A'
alias kl='kubectl logs'
alias kdpod='kubectl describe pod'
alias kdsvc='kubectl describe service'
alias kdvs='kubectl describe vs'

alias 3k9s='k9s --kubeconfig /home/ubuntu/.kube/config-k3s -A'
alias 8k9s='k9s --kubeconfig /home/ubuntu/.kube/config-k8s -A'
EOF
