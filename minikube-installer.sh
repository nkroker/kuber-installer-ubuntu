#!/bin/bash


green=$(tput setaf 2)
normal=$(tput sgr0)


cat << "EOF"
    ____           __        _____                __  ____       _ __ __      __             |\
   /  _/___  _____/ /_____ _/ / (_)___  ____ _   /  |/  (_)___  (_) //_/_  __/ /_  ___       | \
   / // __ \/ ___/ __/ __ `/ / / / __ \/ __ `/  / /|_/ / / __ \/ / ,< / / / / __ \/ _ \      |  \
 _/ // / / (__  ) /_/ /_/ / / / / / / / /_/ /  / /  / / / / / / / /| / /_/ / /_/ /  __/      |  /
/___/_/ /_/____/\__/\__,_/_/_/_/_/ /_/\__, /  /_/  /_/_/_/ /_/_/_/ |_\__,_/_.___/\___/       | /
                                     /____/                                                  |/
EOF




print_message () {
  local message="$1"
  printf "\n\n\n\n"
  printf "%0s\n" "${green}->>>> ${message} <<<<-${normal}"
  printf "\n\n"
}

install_virtualbox () {
  sudo apt install virtualbox virtualbox-ext-pack
}

install_minikube () {
  # Installing additional packages with kubernetes- kubeadm, kubelet, kubectl
  print_message "Downloading and moving minikube executable 🧊"
  wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  chmod +x minikube-linux-amd64
  sudo mv minikube-linux-amd64 /usr/local/bin/minikube


  # Installing additional packages with kubernetes- kubeadm, kubelet, kubectl
  curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl
}

install_docker () {
  print_message " INSTALLING-----CONTAINER------RUNTIME 🧃"

  # Add repo and Install packages
  print_message "Add repo and installing packages"
  sudo apt update
  sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt update
  sudo apt install -y containerd.io docker-ce docker-ce-cli


  # Start and enable Services
  print_message "Start and enable Services ⚙️"
  sudo systemctl enable docker
}


# Updating system
print_message "Updating system 📇"
sudo apt update


# Adding required packages and importing Kubernetes GPG keys
print_message "Adding required packages and importing Kubernetes GPG keys ⚙️🔑"
sudo apt -y install curl apt-transport-https


# Installing Virtualbox
if [[ $(vboxmanage --version) ]]; then
    print_message "VirtualBox Installed already 📦"
  else
    print_message "Installing VirtualBox 📦"
    install_virtualbox
fi


# Installing Minikube
if [[ $(which minikube) ]]; then
    print_message "Minikube Installed already 🧊"
  else
    install_minikube
fi


# Installing Docker
if [[ $(which docker) && $(docker --version) ]]; then
    print_message "Docker Already Installed 🧃"
  else
    install_docker
fi



# Showing Banner
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
