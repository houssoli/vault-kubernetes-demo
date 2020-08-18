# vault-kubernetes-demo

This is a modified version of Brian Kassouf's repo: [vault-kubernetes-demo](https://github.com/briankassouf/vault-kubernetes-demo).  
Updates in this fork:
- Using application specific namespaces
- Updated main.go application to read Environment variables
- Updated Vault CLI commands

**Important: this is a demo. Please do not use this in production.**

## Usage

This is a demo on how to setup the Vault [Kubernetes Auth method](https://www.vaultproject.io/docs/auth/kubernetes.html). The guide will provide steps to configure a Kubernetes Auth method, create service accounts in Kubernetes and run demo applications on Kubernetes that can successfully authenticate to Vault and retrieve a secret.

## Pre-requisites
* Vault server (>0.9.0), and a root or administrative token. There are a few ways to deploy Vault, below are some options. 
  - To deploy a Vault server on a VM please see the [Vault getting started guide](https://learn.hashicorp.com/vault/getting-started/deploy). 
  - To deploy a Vault server on Kubernetes, pelase see [k8s-vault/README.md](k8s-vault/README.md).
  - The easiest way is to deploy it using a Docker command as below:
```
docker rm -f dev-vault
VAULT_VERSION=1.2.0 docker run -p 8200:8200 --cap-add=IPC_LOCK -e 'VAULT_DEV_ROOT_TOKEN_ID=devroottoken' -d --name=dev-vault "vault:${VAULT_VERSION}"
export VAULT_ADDR="http://localhost:8200"; export VAULT_TOKEN="devroottoken"
vault status
```

* Existing Kubernetes cluster. This guide has beek tested on GKE and OpenShift.
* Connectivity between Vault and K8S
* The `ca.crt` file from Kubernetes cluster creation

Example validation commands:
```
vault --version
# Ensure VAULT_ADDR and VAULT_TOKEN environment variables are exported correctly:
vault token lookup
kubectl cluster-info
kubectl get nodes
```

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
