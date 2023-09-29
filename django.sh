#!/bin/bash
echo 'Waiting for file to be available...'
while [ ! -f /tmp/public_ip ]; do sleep 10; done
echo 'File is available, continuing with setup...'
sudo apt update -y
sudo apt install python3-pip -y
sudo apt install python3-virtualenv -y
cd /home/ubuntu
sudo virtualenv connectrdj
source connectrdj/bin/activate
sud pip install django
sudo pip install djangorestframework
sudo pip install psycopg2
sudo git clone https://github.com/abhay9175/djangobackend.git /home/ubuntu/my-git-repo 2>> /home/ubuntu/git_error.log
word_to_replace=$(cat /tmp/public_ip)
sed -i "s/43.205.39.113/$word_to_replace/g" /home/ubuntu/my-git-repo/djangobackend/djangobackend/settings.py
cd /home/ubuntu/my-git-repo/djangobackend/
sudo python3 manage.py runserver 0.0.0.0:8000