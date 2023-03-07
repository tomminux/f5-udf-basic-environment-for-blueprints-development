#!/bin/bash

K3S_CERT_AUTH_DATA=$(cat ~/.kube/config-k3s | grep certificate-authority-data | awk '{print $2}')
K8S_CERT_AUTH_DATA=$(cat ~/.kube/config-k8s | grep certificate-authority-data | awk '{print $2}')

K3S_CLIENT_CERT_DATA=$(cat ~/.kube/config-k3s | grep client-certificate-data | awk '{print $2}')
K8S_CLIENT_CERT_DATA=$(cat ~/.kube/config-k8s | grep client-certificate-data | awk '{print $2}')

K3S_CLIENT_KEY_DATA=$(cat ~/.kube/config-k3s | grep client-key-data | awk '{print $2}')
K8S_CLIENT_KEY_DATA=$(cat ~/.kube/config-k8s | grep client-key-data | awk '{print $2}')

sed "s/<PUT HERE YOUR K3S CERTIFICATE AUTHORITY DATA>/$K3S_CERT_AUTH_DATA/" ~/f5-udf-infra-server/ansible/playbooks/files/config > ~/.kube/config
sed -i "s/<PUT HERE YOUR K8S CERTIFICATE AUTHORITY DATA>/$K8S_CERT_AUTH_DATA/" ~/.kube/config
sed -i "s/<PUT HERE YOUR K3S CLIENT CERTIFICATE DATA>/$K3S_CLIENT_CERT_DATA/" ~/.kube/config
sed -i "s/<PUT HERE YOUR K8S CLIENT CERTIFICATE DATA>/$K8S_CLIENT_CERT_DATA/" ~/.kube/config
sed -i "s/<PUT HERE YOUR K3S CLIENT KEY DATA>/$K3S_CLIENT_KEY_DATA/" ~/.kube/config
sed -i "s/<PUT HERE YOUR K8S CLIENT KEY DATA>/$K8S_CLIENT_KEY_DATA/" ~/.kube/config