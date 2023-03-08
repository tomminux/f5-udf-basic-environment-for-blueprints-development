#!/bin/bash

cp ~/f5-udf-basic-environment-for-blueprints-development/ansible/playbooks/files/docker-files/registry.* ~/.
rm -rf ~/f5-udf-basic-environment-for-blueprints-development
git clone https://github.com/tomminux/f5-udf-basic-environment-for-blueprints-development
cp ~/registry.* ~/f5-udf-basic-environment-for-blueprints-development/ansible/playbooks/files/docker-files/.