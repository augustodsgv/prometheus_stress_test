TOKEN=$1
ADDR=$2
sudo apt update && sudo apt upgrade -y
curl -fsSL get.docker.com | sudo sh
sudo groupadd docker
sudo usermod -aG docker $USER
echo "All set, now run"
newgrp docker
echo "docker swarm join --token $TOKEN $ADDR"