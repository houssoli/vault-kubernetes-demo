# Configure Kubernetes

This guide will walk you configuring Vault's Kubernetes Auth method

## Configure Service Accounts in Kubernetes

The Kubernetes Authentication method has a `token_reviewer_jwt` field which 
takes a Service Account Token that is in charge of verifying the validity of 
other service account tokens. This Service Account will call into Kubernetes
TokenReview API and verify the service account tokens provided during login
are valid. 

### Prerequisites

Vault uses the Kubernetes TokenReview API to validate that JWT tokens are still
valid, and have not been deleted from within Kubernetes.

To ensure stale/deleted Service Accounts tokens can not authenticate with vault
the Kubernetes API server must be running with `--service-account-lookup`. This
is defaulted to on in Kubernetes 1.7 but prior versions should ensure this is
set.

### Create vault-demo namespace and application related Service Accounts:
In this guide we will be using an application specific Namespace called `vault-demo`. Application service accounts will be created in this namespace. These application service accounts do not need any RBAC permissions.
```
kubectl apply -f vault-demo-ns.yaml
kubectl apply -f k8s-app1.yaml
kubectl apply -f k8s-app2.yaml
kubectl get ns
kubectl get sa -n vault-demo
```

### Create the vault-reviewer Service Account
The `vault-reviewer` service account 
```
kubectl create -f vault-reviewer.yaml
kubectl get sa
```

### RBAC 
If your kubernetes cluster uses RBAC authorization you will need to provide the
service account with a role that gives it access to the TokenReview API. 
```
kubectl create -f vault-reviewer-rbac.yaml
```
The above command will create a ClusterRoleBinding for the `vault-reviewer` service account to the `system:auth-delegator` ClusterRole. To view the permissions of this role, please issue: `kubectl describe ClusterRole system:auth-delegator`. You will notice PolicyRule that allows tokenreview and subjectaccessreview API calls.

### Read Service Account Token
This token will need to be provided to Vault in the next step. The following command will save out the Service Account JWT token (requires `jq`) in the file: `vault-reviewer-token.txt`.
```
kubectl get secret $(kubectl get serviceaccount vault-reviewer -o json | jq -r '.secrets[0].name') -o json | jq -r '.data.token' | base64 --decode > vault-reviewer-token.txt
cat vault-reviewer-token.txt
```

## Next Steps

We now have a service account setup with the appropriate permissions. Next we
will configure the [Kubernetes Auth method](./2-configure-vault.md) in Vault.
