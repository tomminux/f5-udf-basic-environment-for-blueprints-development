#!/bin/bash

## ============================================================================
##
## 1.infra-server.sh Init Script
##
## Author:  Paolo Tomminux Arcagni - F5
## Date:    November 2020
## Version: 1.0
##
## This script can be used to initialize the configuration on the infra-server
## in F5 UDF Environment to adapt it to the environment itself and prepare it to
## execute needed stuff to operate demos.
##
## Execute this script as "ubuntu" user on infra-server
##
##
##
##
## ============================================================================

## ..:: infra-server's configuration checks ::..
## ----------------------------------------------------------------------------

IFACE_CHECK=$(ip address show | grep "mtu" | awk -F":" '{print $2}' | wc -l)
if [ "$IFACE_CHECK" -ne "3" ]
then
    echo "Something wrong with infra-server's networking configuration in UDF"
    exit 0
else
    echo "infra-server's networking configuration seems OK"
fi

IFACE_NAME=$(ip address show | grep "mtu" | awk -F":" '{print $2}' | sed '3q;d')

## ..:: SSH Keys Initialization phase ::..
## ----------------------------------------------------------------------------

# -> Creating SSH keys for user "root" and "ubuntu"

sudo ssh-keygen -b 2048 -t rsa
sudo sh -c 'cp /root/.ssh/id_rsa* /home/ubuntu/.ssh/.'
sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/id*
sudo sh -c 'cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys'
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

## ..:: Ubuntu distibution update to latest software releases ::..
## ----------------------------------------------------------------------------

DEBIAN_FRONTEND=noninteractive
sudo apt update
sudo apt upgrade -y
sudo apt autoremove
#sudo do-release-upgrade -f DistUpgradeViewNonInteractive

## ..:: Base system and networking configuration ::..
## ----------------------------------------------------------------------------

sudo sh -c 'echo "infra-server" > /etc/hostname'

cat <<EOF > rc.local
#!/bin/bash
ip address add 10.1.20.4/24 dev $IFACE_NAME
ip address add 10.1.20.20/24 dev $IFACE_NAME
ip address add 10.1.20.30/24 dev $IFACE_NAME
ip address add 10.1.20.100/24 dev $IFACE_NAME
ip link set dev $IFACE_NAME up

## ..:: Max Map Count for VM when runnign ELK in a Docker container ::..
sysctl -w vm.max_map_count=262144

exit 0
EOF

sudo chown root:root rc.local
sudo mv rc.local /etc/.
sudo chmod 755 /etc/rc.local

sudo reboot
