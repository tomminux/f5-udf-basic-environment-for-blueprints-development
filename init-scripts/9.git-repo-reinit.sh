#!/bin/bash

rm -rf f5-udf-infra-server f5-udf-k8s-deployments k3s-manifests k8s-manifests udf-aspenmesh-k8s-slim
git clone https://github.com/tomminux/udf-aspenmesh-k8s-slim.git
git clone https://github.com/tomminux/f5-udf-infra-server.git
git clone https://github.com/tomminux/f5-udf-k8s-deployments.git
rsync -a /home/ubuntu/f5-udf-infra-server/ansible/playbooks/files/k3s-manifests /home/ubuntu/.
rsync -a /home/ubuntu/f5-udf-k8s-deployments/ansible/playbooks/files/k8s-manifests /home/ubuntu/.