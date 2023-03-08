#!/bin/bash

docker run -d \
    -p 10.1.20.30:5000:5000 \
    --restart=always \
    --name f5Registry \
    -v /home/ubuntu/dockerhost-storage/registry/ca-certificates:/certs \
    -v /home/ubuntu/dockerhost-storage/registry/var-lib-registry:/var/lib/registry \
    -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt \
    -e REGISTRY_HTTP_TLS_KEY=/certs/registry.key \
    -e REGISTRY_HTTP_ADDR=0.0.0.0:5000 \
    registry:2
    