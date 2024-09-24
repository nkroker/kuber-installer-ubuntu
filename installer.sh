#!/bin/bash


green=$(tput setaf 2)
normal=$(tput sgr0)


cat << "EOF"
    __         __ _
   / /   ___  / /( )_____   ____ _____
  / /   / _ \/ __/// ___/  / __ `/ __ \
 / /___/  __/ /_  (__  )  / /_/ / /_/ /
/_____/\___/\__/ /____/   \__, /\____/
                         /____/
EOF

printf "\n\n\n\n\n\n"
printf "%0s\n" "${green}Updating system${normal}"
printf "\n\n"
# Updating system
sudo apt update
sudo apt -y upgrade && sudo sysctl --system


printf "\n\n\n\n"
printf "%0s\n" "${green}Adding required packages and importing Kubernetes GPG keys${normal}"
printf "\n\n"
# Adding required packages and importing Kubernetes GPG keys
sudo apt -y install apt-transport-https ca-certificates curl gpg socat

# Get the Ubuntu release version number for pre check
version=$(lsb_release -r | awk '{print $2}')

# Compare the version with 22.04
if [[ "$(printf '%s\n' "$version" "22.04" | sort -V | head -n1)" == "$version" && "$version" != "22.04" ]]; then
  # If version is smaller than 22.04, create the directory
  echo "Version is smaller than 22.04. Creating directory..."
  mkdir -p /etc/apt/keyrings
else
  echo "Version is 22.04 or higher. No action needed."
fi

# Importing reselase key and also adding apt repository
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list


printf "\n\n\n\n"
printf "%0s\n" "${green}Installing additional packages with kubernetes- kubeadm, kubelet, kubectl${normal}"
printf "\n\n"
# Installing additional packages with kubernetes- kubeadm, kubelet, kubectl
sudo apt update
sudo apt -y install nano vim git curl wget kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

printf "\n\n\n\n"
printf "%0s\n" "${green}Versions${normal}"
printf "\n\n"
# Printing versions
echo $(kubectl version --client && kubeadm version)


printf "\n\n\n\n"
printf "%0s\n" "${green}Disabling Swap${normal}"
printf "\n\n"
# Disabling Swap
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a


printf "\n\n\n\n"
printf "%0s\n" "${green}Enable kernel modules${normal}"
printf "\n\n"
# Enable kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter


printf "\n\n\n\n"
printf "%0s\n" "${green}Add some settings to sysctl${normal}"
printf "\n\n"
# Add some settings to sysctl
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF


printf "\n\n\n\n"
printf "%0s\n" "${green}Reload sysctl${normal}"
printf "\n\n"
# Reload sysctl
sudo sysctl --system



printf "\n\n\n\n"
printf "%0s\n" "${green}---------------------------------INSTALLING-----CONTAINER------RUNTIME------------------------------${normal}"
printf "\n\n"
# ---------------------------------INSTALLING-----CONTAINER------RUNTIME------------------------------

printf "\n\n\n\n"
printf "%0s\n" "${green}Add repo and installing packages${normal}"
printf "\n\n"
# Add repo and Install packages
sudo apt update
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io docker-ce docker-ce-cli


printf "\n\n\n\n"
printf "%0s\n" "${green}Create required directories${normal}"
printf "\n\n"
# Create required directories
sudo mkdir -p /etc/systemd/system/docker.service.d


printf "\n\n\n\n"
printf "%0s\n" "${green}Create daemon json config file${normal}"
printf "\n\n"
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
printf "%0s\n" "${green}Start and enable Services${normal}"
printf "\n\n"
# Start and enable Services
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker


printf "\n\n\n\n"
printf "%0s\n" "${green} Setting up the envirionment${normal}"
printf "\n\n"
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
