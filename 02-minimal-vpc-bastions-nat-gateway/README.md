# What is a VPC

# Architecture Designs

## Basic Architecture

## Environment Segmented Architecture

## Region Segmented Architecture

# Basic Architecture

```
eval `ssh-agent`
ssh-add
```

`ssh -A user@DNS_NAME`


Bastion SSH hosts
* Just copy keys manually. Will work on automating later

```
cd /etc/ssh
tar -cvf ssh_keys.tar ssh_host_*_key
scp ssh_keys.tar root@BASTION_HOST_IP

ssh root@BASTION_HOST_IP
mv ~/ssh_keys.tar
rm -rf ssh_host_*_key
tar -xvf ssh_keys.tar

systemctl restart sshd
systemctl status sshd # Check to for any errors
```
Users can use the load balancer. However, there are still DNS records for each
individual bastion in case load balancer goes down.