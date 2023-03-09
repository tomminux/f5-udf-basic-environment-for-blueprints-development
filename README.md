# infra-server Development Notes

## UDF Preparation

- Create a new deployment in UDF - London / Frankfurt (you decide)

### Networking

- Add the External network 10.1.10.0/24
- Add the Internal network 10.1.20.0/24

### infra-server Ubuntu Server

- Add a new Ubuntu 20.04 LTS Server

````
Name: infra-server
vCPUs: 8
Memory: 32 GiB
Disk Size: 100 GiB
````

- Bind the server to the internal network

````
Internal -> 10.1.20.4
10.1.20.20
10.1.20.30
10.1.20.100
````

### bigip-cis TMOS

- Add a new BIG-IP 17.0.0.1-0.0.4 box

````
vCPUs: 8
Memory: 32 GiB
Disk Size: 105 GiB
````

- Bind TMOS to internal and external networks

````
Internal -> 10.1.10.5
External -> 10.1.20.5
````

### F5 Distributed Cloud CE

- Add e new F5 XC Customer Edge node (volterra)

`````
Name: f5-xc-ce-node
vCPUs: 8
Memory: 32 GiB
Disk Size: 105 GiB
`````

- Bind TMOS to internal networks

````
Internal -> 10.1.10.6
````

### k3s-server Ubuntu Server

- Add a new Ubuntu 20.04 LTS Server

````
Name: k3s-server
vCPUs: 8
Memory: 32 GiB
Disk Size: 100 GiB
````

- Bind the server to the internal network

````
Internal -> 10.1.20.7
10.1.20.60
````

## infra-server setup and configuration

### Init Scripts execution

Connect via ssh to infra-server and execute the first init-script

````
git clone https://github.com/tomminux/f5-udf-basic-environment-for-blueprints-development.git

cd f5-udf-basic-environment-for-blueprints-development/
bash init-scripts/1.infra-server.sh
````

After the reboot, execute the second script

````
cd f5-udf-basic-environment-for-blueprints-development/
bash init-scripts/2.infra-server-postReboot.sh
sudo reboot
````

### Add an Access Method to UDF Deployment for Coder Server

In the UDF Deployment, create an Access Method with this profile:

````
Label: Coder Server
Protocol: HTTPS
Instance Address: 10.1.20.100
Instance Port: 8080
No SSL, No Unauthenticated, No Path
````

With that method, you can access Visual Studio Code running inside infra-server: from there, it is super easy to modify files online. 

### Self-signed Certificate for the Private Registry

In order to correctly access the docker private registry with HTTPS, we need to initialize a new self-signed certificate:

````
cd ~/f5-udf-basic-environment-for-blueprints-development/ansible/playbooks/files/docker-files/
openssl req -addext "subjectAltName = DNS:registry.f5-udf.com" -newkey rsa:4096 -nodes -sha256 -keyout registry.key -x509 -days 3650 -out registry.crt
````

### infra-server: base deployment with Ansible 

The basic deployment on infra-server is going to:

- Upgrade all ubuntu packages
- Set the timezone
- copy hosts file 
- Install a bunch of needed software
- Install the kubectl command
- Install the HELM package management system

````
cd ~/f5-udf-basic-environment-for-blueprints-development/ansible/
ansible-playbook playbooks/install-infra-server-base-deploy.yaml
````

### infra-server: F5 CLI Installation

The F5 CLI Installation on infra-server is going to:

- Initialize directories in dockerhost-storage
- Create necessary aliases

````
cd ~/f5-udf-basic-environment-for-blueprints-development/ansible/
ansible-playbook playbooks/install-infra-server-f5-cli.yaml
````

### infra-server: Docker Private Registry Installation

The docker private server installation on infra-server is going to:

- Configure Docker to use self signed certificates
- Initialize directories in dockerhost-storage
- Start the docker registry container

````
cd ~/f5-udf-basic-environment-for-blueprints-development/ansible/
ansible-playbook playbooks/install-infra-server-registry.yaml
````

### infra-server: k9s Installation

The k9s installation on infra-server is going to:

- Download and install the "brew" package management system
- Install k9s via Brew. 

````
cd ~/f5-udf-basic-environment-for-blueprints-development/ansible/
ansible-playbook playbooks/install-infra-server-k9s.yaml
````

After a good exit status of this Ansible playbook, in order to execute the "k9s" command you shoud logout and re-login to infra-server

### --OPTIONAL-- infra-server: k3s Installation

The k3s installation on infra-server is going to:  

- Install k3s via bash / curl command
- Create a .kube directory for the ubuntu user
- Create the config-k3s configuration file to access the new k3s cluster
- Install the Calico Overlay networking configuring it to use 10.243.0.0/16 network, disabling Traefik and the defaul network policy

````
cd ~/f5-udf-basic-environment-for-blueprints-development/ansible/
ansible-playbook playbooks/OPTIONAL-install-infra-server-k3s.yaml
````

After a good exit status of this Ansible playbook, in order to execute the "k9s" command you shoud logout and re-login to infra-server

### k3s-server: k3s installation

On infra-server, copy the content of the public key:

    cat ~/.ssh/id_rsa.pub

On k3s-server execute the following procedure:

    echo "<put your public key here>" >> ~/.ssh/authorized_keys
    sudo su -
    echo "<put your public key here>" >> ~/.ssh/authorized_keys
    exit
    exit

On infra server, execute the following playbook

````
cd ~/f5-udf-basic-environment-for-blueprints-development/ansible/
ansible-playbook playbooks/install-k3s-server-k3s.yaml
````

## BIG-IP bigip-cis Onboarding and Configuration

### Admin passwd reset and license the box

Connect to the web console of BIG-IP and change the password

    tmsh modify auth user admin password xxxxxxxxxx
    
Connect to the TMUI and license the box

### Declarative Oboarding the BIG-IP

Connect to infra-server and use the F5 CLI Docker Container to run a DO scrpt to upload basic configuration to BIG-IP

````
runf5cli f5 login --authentication-provider bigip --host 10.1.1.5 --user admin
runf5cli f5 config set-defaults --disable-ssl-warnings true
runf5cli f5 bigip extension do install
runf5cli f5 bigip extension as3 install
runf5cli f5 bigip extension ts install

runf5cli f5 bigip extension do create --declaration do/bigip-cis-do.json
````

### Configure BGP Routing to talk to K3s' Calico Overlay Network

Connect to the TMUI and enable BGP for route domain 0

Connect to the web console of BIG-IP and configure BGP to talk to k3s cluster's Calico:

````
imish

ena
conf t

router bgp 64512
neighbor calico-k3s peer-group
neighbor calico-k3s remote-as 64512
neighbor 10.1.1.7 peer-group calico-k3s 
wr
end
````

Verify BGP is working with k3s, diplaying routes and BGP Neighbors

````
show ip route
show bgp neighbors
````

### Configure BIG-IP CIS on k3s-server and BIG-IP

Notes taken from the original F5 Clouddocs documentation: [CIS Installation](https://clouddocs.f5.com/containers/latest/userguide/cis-installation.html)

On BIG-IP, create the "ingress-services" partition:

    tmsh create auth partition ingress-services

Connect to infra-server and execute the following asible playbook:

    cd ~/f5-udf-basic-environment-for-blueprints-development/ansible/
    ansible-playbook playbooks/install-bigip-cis-via-helm.yaml