# vault-kubernetes-demo

This is a modified version of Brian Kassouf's repo: [vault-kubernetes-demo](https://github.com/briankassouf/vault-kubernetes-demo).  
Updates in this fork:
- Using application specific namespaces
- Updated main.go application to read Environment variables
- Updated Vault CLI commands

**Important: this is a demo. Please do not use this in production.**

## Usage

This is a demo on how to setup the Vault [Kubernetes Auth method](https://www.vaultproject.io/docs/auth/kubernetes.html). The guide will provide steps to configure a Kubernetes Auth method, create service accounts in Kubernetes and run demo applications on Kubernetes that can successfully authenticate to Vault and retrieve a secret.

## Steps
Git clone this repo using the command below and follow README guides:
```
git clone https://github.com/kawsark/vault-kubernetes-demo.git
cd vault-kubernetes-demo
```

This guide has a few parts:
1. [Configure Kubernetes](1-configure-kubernetes.md)
2. [Configure Vault server](2-configure-vault.md)
3. [Deploy the basic example](3-deploy-basic.md)
4. [Deploy the sidecar example](4-deploy-sidecar.md) Note: pending updates
5. [Deploy the AWS secrets engine example](5-deploy-aws.md) Note: pending updates
