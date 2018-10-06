# ansible-testing
There's a lot of well written documentation, 101s, and so on for ansible, this is like a cheat sheet with a little more details and real life examples.

## Concepts:

-Playbooks tell ansible what to do

-Playbooks are expressed in YAML format

-Each playbook is composed of one or more ‘plays’ in a list

-Playbooks start with 3 dashes: --- (because we don’t need metadata/front matter in our YAML files)

-TABs and spaces means something within YAML syntax

-Plays maps a group of hosts to some well defined roles, represented by tasks

-Task is nothing more than a call to an ansible module

-Each play is defined as a list entry and has to have at least two keys, hosts and tasks (or roles)

-Playbooks can contain multiple plays (each play can have many tasks). You may have a playbook that targets first the web servers and then the database servers:

```
---
- hosts: webservers
  remote_user: root

  tasks:
  - name: ensure apache is at the latest version
    yum:
      name: httpd
      state: latest

- hosts: databases
  remote_user: root

  tasks:
  - name: ensure postgresql is at the latest version
    yum:
      name: postgresql
      state: latest
  - name: ensure that postgresql is started
    service:
      name: postgresql
      state: started
```

### Playbook’s anatomy:

-Where to run:
```
----
- hosts: all
```
-What to run (which module):
```
----
- hosts: all
  tasks:
    - ping:
```
Here we add a name to our previous task:
```
---
- hosts: all
  tasks:
     - name: Make sure that we can connect to the machine
       ping:
```

What this will do: The output of the playbook instead of saying:
```
TASK: [ping ]
```
Will say:
```
TASK: [Make sure that we can connect to the machine]
```
Notice the indentation for the previous examples.


### Dynamic inventory for AWS:

-Copy your public key to avoid prompting for password (there are many ways to enable ssh handling in ansible):
ssh-copy-id user@clienthost
If you don’t have a key, create one using ssh-keygen

-Make sure to have python and boto installed

-Configure an AWS user with the permissions you need (IAM)

-Get ec2.py and ec2.ini to your inventory directory (you can use the script in this repo: get-ec2-ansible.sh)

-Tell ansible to use your inventory directory (no files, just the directory, it’s recursive)

-You can: cp /etc/ansible/ansible.cfg /home/<youruser>/ansible/ Ansible will pick it up from there

-Run inventory/ec2.py 

Testing time:
```
ansible all -m ping
```

### Posible Issues

- When executing ec2.py script for the first time, if you get:

```
ERROR: "Forbidden", while: getting ElastiCache clusters
```

Uncomment the next line at ec2.ini file:
```
#elasticache = False
```

- Failing to execute against localhost:
```
<your-host-ip> | UNREACHABLE! => {                                                                                                                                                                                                               "changed": false,                                                                                                                                                                                                                            "msg": "Failed to connect to the host via ssh
```
Ansible, by default, tries to connect via SSH (I have the server at AWS so it will execute modules against itself when using "all"), there are many ways to solve this:
Add "--connection=local" next to your ansible command, like this:

```
ansible -i inventory/ec2.py all -m ping --connection=local
```
Add to your playbook:
```
- hosts: local
  connection: local
```
Or, preferable, define it as a host var just for localhost/127.0.0.1. Create a file host_vars/127.0.0.1 relative to your playbook with this content:
```
ansible_connection: local
```
You also could add it as a group var in your inventory:
```
[local]
127.0.0.1

[local:vars]
ansible_connection=local
```
or as a host var:
```
[local]
127.0.0.1   ansible_connection=local
```
Source: https://stackoverflow.com/questions/37184699/ansible-ssh-error-connection-in-localhost  (udondan's answer)

### Shell aliases:
At Ubuntu I set them at ~/.bash_aliases

At Centos/Linux AMI2 I set them at ~/.bash_profile

Shortcut to ansible-playbook command:
```
alias ap='ansible-playbook'
```
Ping all hosts:
```
alias aping='ansible -m ping all'
```
