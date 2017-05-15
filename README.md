# terra-aws-core-kube

## Description
This repository is an example configuration of using Terraform to bootstrap a
Kubernetes Cluster on top of CoreOS using AWS-EC2 instances.
Contributions are more than welcome.

## Setup-Instructions

### Custom settings
- Rename `_variables-aws-custom.tf.sample` to `_variables-aws-custom.tf` and put in your own settings.

### Get kubectl
`curl -O https://storage.googleapis.com/kubernetes-release/release/v1.6.3/bin/linux/amd64/kubectl`

### SSH-Key
Put your ssh-key into the `ssh/` folder. Make sure it named like the key stored in AWS and ends with `.pem`.

### Deploy
- Run `terraform plan`.
- Run `terraform apply`.
- Wait a little while for the Cluster to spin up.
- When `kubectl get nodes` returns all your nodes, the cluster is ready for further configuration (like setting up DNS pods).

### Use
Now you can use the Terraform output to ssh into your instances and use your
local kubectl to interact with the Kubernetes-API.
