## Configure the Kubernetes Auth Method in Vault 

### Configuring the Auth method
Export VAULT_ADDR and VAULT_TOKEN environment variables:
```
export VAULT_ADDR="http://vault_server_dns:8200"
export VAULT_TOKEN=root_or_admin_token
vault status
vault token lookup
```

At this point we will need:
- The vault-reviewer JWT Token we created earlier
- The endpoint Kubernetes API server
- CA certificate used by API server.

Typically this information can be found by using `kubectl config view`. Here are some example commands to extract these using `jq` (assuming the first cluster in `kubectl config view` is the one you want to use):
```
# Obtain the K8S API server:
export k8s_api_server=$(kubectl config view --raw -o json | jq -r '.clusters[0].cluster.server')
echo ${k8s_api_server}
kubectl cluster-info

# Obtain the K8S API server CA information:
export VAULT_SA_NAME=$(kubectl get sa vault-reviewer -o jsonpath="{.secrets[*]['name']}")
export SA_CA_CRT=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)
echo ${SA_CA_CRT} > ca.crt
cat ca.crt
```

Mount the kubernetes auth method at default path and configure using the above information
```
vault auth enable kubernetes
vault write auth/kubernetes/config \
    token_reviewer_jwt=$(cat vault-reviewer-token.txt)  \
    kubernetes_host=${k8s_api_server} \
    kubernetes_ca_cert=@ca.crt
```

### Configuring a Role for App1:

Roles are used to bind Kubernetes Service Account names and namespaces to a set
of Vault policies and token settings. 

First create the policy we want this role to gain:
```
cat app1-policy.hcl
vault policy write app1-policy app1-policy.hcl
```

Create a role with the Service Account name `app1` in the `vault-demo` namespace:
```
vault write auth/kubernetes/role/app1 \
    bound_service_account_names=k8s-app1 \
    bound_service_account_namespaces=vault-demo \
    policies=app1-policy \
    period=60s

vault read auth/kubernetes/role/app1
```

Notice we set a period of 60s, this means the resulting token is a [periodic token](https://www.vaultproject.io/docs/concepts/tokens.html#periodic-tokens) and
must be renewed by the application at least every 60s.

Read the demo role to verify everything was configured properly:

```
vault read auth/kubernetes/role/app1
```
Should produce the following output:
```
Key                                 Value
---                                 -----
bound_cidrs                         []
bound_service_account_names         [k8s-app1]
bound_service_account_namespaces    [vault-demo]
max_ttl                             0s
num_uses                            0
period                              1m
policies                            [app1-policy]
ttl                                 0s
```

### Write a secret

This will be used later in the demo

```
vault write secret/creds username=demo password=test
```

## Next Steps

We now have a service account setup with the appropriate permissions and a Vault
server configured to authenticate Service Account JWT tokens for the `k8s-app1`
Service Account in the `vault-demo` namespace. Next we will [deploy a basic
application](./3-deploy-basic.md).
