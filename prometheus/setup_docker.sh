sudo apt update && sudo apt upgrade -y
curl -fsSL get.docker.com | sudo sh
sudo groupadd docker
sudo usermod -aG docker $USER
echo "All set"
newgrp docker