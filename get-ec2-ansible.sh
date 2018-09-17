#!/bin/bash
cd ~/ansible/inventory/ && \
  wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.py && \
  wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.ini && \
  chmod +x ec2.py 
  
