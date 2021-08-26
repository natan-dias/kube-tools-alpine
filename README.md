[![Build status](https://dev.azure.com/natan-dias/Kube-tools/_apis/build/status/Kube-tools-Alpine%20CI)](https://dev.azure.com/natan-dias/Kube-tools/_build/latest?definitionId=-1)

# Kube Tools - Alpine

Docker image with tools for Kubernets administration and Debug.

Alpine base image.

## Latest version features:

+ Kubectl CLI
+ Docker CLI
+ httping
+ nmap
+ jq (JSON Processor)
+ httpd-tools
+ OpenSSL
+ Vim
+ Curl

## Docker Hub Repo

To use this image in Docker or Podman:

> docker pull natandias1/kube-tools-alpine:TAG (you can use "latest" TAG)
>
> podman pull natandias1/kube-tools-alpine:TAG (you can use "latest" TAG) 

## Kubernetes

To use in kubernetes: Use YAML file!

> kubectl apply -f ktools.yaml
>
> kubectl attach -n ktools -it ktools
