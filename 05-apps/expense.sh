#!/bin/bash
dnf install ansible -y
cd /tmp
git clone https://github.com/Ashok-Maruvada/expense-ansible-roles.git
cd expense-ansible-roles
ansible-playbook -e login_password=ExpenseApp1 -e component=backend main.yaml
ansible-playbook -e component=frontend main.yaml