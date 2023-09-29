#!/bin/bash
sudo apt update
sudo apt install python3-pip
sudo apt install python3-virtualenv
virtualenv connectrdj
source connectrdj/bin/activate
pip install django
pip install djangorestframework
pip install psycopg2
sudo git clone https://github.com/abhay9175/djangobackend.git /home/ubuntu/my-git-repo 2>> /home/ubuntu/git_error.log
cd djangobackend/
python3 manage.py runserver 0.0.0.0:8000