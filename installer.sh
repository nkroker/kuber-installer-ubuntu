#!/bin/bash


cat << "EOF"
    __         __ _
   / /   ___  / /( )_____   ____ _____
  / /   / _ \/ __/// ___/  / __ `/ __ \
 / /___/  __/ /_  (__  )  / /_/ / /_/ /
/_____/\___/\__/ /____/   \__, /\____/
                         /____/
EOF

printf "\n\n\n\n\n\n"
# Updating system
sudo apt update
sudo apt -y upgrade && sudo sysctl --system


printf "\n\n\n\n"
# Adding required packages and importing Kubernetes GPG keys
sudo apt -y install curl apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list


printf "\n\n\n\n"
# Installing additional packages with kubernetes- kubeadm, kubelet, kubectl
sudo apt update
sudo apt -y install vim git curl wget kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

printf "\n\n\n\n"
# Printing versions
echo $(kubectl version --client && kubeadm version)


printf "\n\n\n\n"
# Disabling Swap
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a


printf "\n\n\n\n"
# Enable kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter


printf "\n\n\n\n"
# Add some settings to sysctl
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF


printf "\n\n\n\n"
# Reload sysctl
sudo sysctl --system




# ---------------------------------INSTALLING-----CONTAINER------RUNTIME------------------------------

printf "\n\n\n\n"
# Add repo and Install packages
sudo apt update
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io docker-ce docker-ce-cli


printf "\n\n\n\n"
# Create required directories
sudo mkdir -p /etc/systemd/system/docker.service.d


printf "\n\n\n\n"
# Create daemon json config file
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF


printf "\n\n\n\n"
# Start and enable Services
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker


printf "\n\n\n\n"
# Setting up the envirionment
lsmod | grep br_netfilter
sudo systemctl enable kubelet

printf "\n\n\n\n\n\n"
cat << "EOF"
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣠⣶⡾⠏⠉⠙⠳⢦⡀⠀⠀⠀⢠⠞⠉⠙⠉⠙⠉⠙⠉⠙⠉⠙⠲⡀
⠀⠀⠀⣴⠿⠏⠀⠀⠀⠀⠀⠀⢳⡀⠀ ⡏⠀⠀⠀⠀⠀        ⢷
⠀⠀⢠⣟⣋⡀⢀⣀⣀⡀⠀⣀⡀⣧⠀⢸⠀⠀⠀⠀⠀          ⡇
⠀⠀⢸⣯⡭⠁⠸⣛⣟⠆⡴⣻⡲⣿⠀⣸⠀⠀ Done Boss⠀  ⡇
⠀⠀⣟⣿⡭⠀⠀⠀⠀⠀⢱⠀⠀⣿⠀⢹⠀⠀⠀⠀⠀          ⡇
⠀⠀⠙⢿⣯⠄⠀⠀⠀⢀⡀⠀⠀⡿⠀⠀⡇⠀⠀⠀⠀         ⡼
⠀⠀⠀⠀⠹⣶⠆⠀⠀⠀⠀⠀⡴⠃⠀⠀⠘⠤⣄⣠⣄⣠⣄⣠⣄⣠⣠⣄⣠⠞
⠀⠀⠀⠀⠀⢸⣷⡦⢤⡤⢤⣞⣁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⢀⣤⣴⣿⣏⠁⠀⠀⠸⣏⢯⣷⣖⣦⡀⠀⠀⠀⠀⠀⠀
⢀⣾⣽⣿⣿⣿⣿⠛⢲⣶⣾⢉⡷⣿⣿⠵⣿⠀⠀⠀⠀⠀⠀
⣼⣿⠍⠉⣿⡭⠉⠙⢺⣇⣼⡏⠀⠀⠀⣄⢸⠀⠀⠀⠀⠀⠀
⣿⣿⣧⣀⣿.........⣀⣰⣏⣘⣆⣀⠀⠀
EOF