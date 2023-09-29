#!/bin/bash
cd /home/ubuntu
sudo apt update -y
sudo apt-get install git -y
sudo mkdir -p /home/ubuntu/my-git-repo
sudo git clone https://github.com/abhay9175/reactfrontend.git /home/ubuntu/my-git-repo 2>> /home/ubuntu/git_error.log
sudo apt update
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt install -y nodejs
node -v
sudo apt update
sudp apt install -y npm
npm -v
sudo chown -R ubuntu:ubuntu /home/ubuntu/my-git-repo/reactfrontend
cd /home/ubuntu/my-git-repo/reactfrontend/
# # Sleep for 2 minutes (120 seconds)
# sleep 120
# # Run the build command after the delay
npm install
npm audit fix
nohup npm start &
# sudo npm run-script build