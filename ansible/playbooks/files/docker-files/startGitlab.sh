#!/bin/bash

docker run -d \
    --hostname gitlab.f5-udf.com
    -p 10.1.20.20:22:22 \
    -p 10.1.20.20:80:80 \
    -p 10.1.20.20:443:443 \
    --restart=always \
    --name f5Gitlab \
    --shm-size 256m \
    -v /home/ubuntu/dockerhost-storage/gitlab/config:/etc/gitlab \
    -v /home/ubuntu/dockerhost-storage/gitlab/logs:/var/log/gitlab \
    -v /home/ubuntu/dockerhost-storage/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ee:latest
    