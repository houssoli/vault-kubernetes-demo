## Deploy the basic example

This example application will read the servcie account JWT token and use it to
authenticate with Vault. It will then log the token (don't log secrets in a
real application!) and keep the token renewed.

### Build the basic example application and container (optional)

The basic-example application is available publicly in Dockerhub: [https://hub.docker.com/r/kawsark/vault-example-init/tags](https://hub.docker.com/r/kawsark/vault-example-init/tags). However, most K8S installations will have restrictions regarding approved container registries. The steps below will help compile the application, build the container, then push the application to an approved registry.

#### Install Go runtime and download Vault SDK:
```
# Install Go runtime: 
sudo apt-get install wget -y
wget https://dl.google.com/go/go1.12.1.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.12.1.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Download the Go SDK for Vault:
go get github.com/hashicorp/vault/api
ls $HOME/go/src/github.com/hashicorp/vault/
```
#### Compile application
```
cd basic/
./build
```
If you do `ls` you will see a `vault-init` executable file which was output from Go compiler. In `Dockerfile` this executable will be added as the Entrypoint: `ENTRYPOINT ["/vault-init"]`

#### Build container and push to container registry
Substitute your `<usermame>` and `<tag>` for command below:
```
docker login
docker build -t <username>/vault-example-init:<tag> .
docker images
docker push <username>/vault-example-init
```

### Run the basic example
Edit `deployment.yaml` and adjust the following:
- `VAULT_ADDR` should be updated to your vault server endpoint
- `image` should be adjusted with your image tag - if you chose to compile the application and build the container. If you have access to public images in Dockerhub, you can leave the default of `kawsark/vault-example-init:<tag>` 

Now we can run the application:
```
kubectl create -f deployment.yaml
```

### View the logs
```
export ns="vault-demo"
kubectl get deployment -n ${ns}
kubectl get pods -n ${ns}
kubectl logs -f  $(kubectl \
    get pods -l app=basic-example \
    -o jsonpath='{.items[0].metadata.name}' -n ${ns}) -n ${ns}
```

You should see log output similar to:
```
2019/04/03 03:23:49 ==> WARNING: Don't ever write secrets to logs.
2019/04/03 03:23:49 ==>          This is for demonstration only.
2019/04/03 03:23:49 s.BEbO4cUuOjDRmE5cWdBJvkJb
2019/04/03 03:23:49 secret secret/creds -> &{baf36983-9af2-8632-07f4-5a5e9e89dd54  2764800 false map[password:test username:demo] [] <nil> <nil>}
2019/04/03 03:23:49 Starting renewal loop
2019/04/03 03:23:49 Successfully renewed: &api.RenewOutput{RenewedAt:time.Time{wall:0x1d990038, ext:63689858629, loc:(*time.Location)(nil)}, Secret:(*api.Secret)(0xc000050ae0)}
2019/04/03 03:23:49 secret secret/creds -> &{5e082322-368f-327a-725b-0c22c6e6f9b1  2764800 false map[password:test username:demo] [] <nil> <nil>}
```

Then you should see a token renewal approximately every 20s.

### Using Curl to access Vault REST API
The Docker image is built from Alpine Linux and has the curl and jq utilities installed. To use the curl commands, please open a shell to the running container and use the example commands below. 
```
# Open up a shell into running Pod:
kubectl get pods -n ${ns}
kubectl exec -it <pod_name> "sh" -n ${ns}

# Obtain JWT and create payload:
export jwt=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
cat <<EOF > payload.json
{
  "role":"${VAULT_ROLE}",
  "jwt":"${jwt}"
}
EOF
cat payload.json

# Authenticate using JWT and export VAULT_TOKEN
curl \
   --request POST \
   --data @payload.json \
   ${VAULT_ADDR}/v1/auth/kubernetes/login | jq . > vault_auth_response.txt
export VAULT_TOKEN=$(cat vault_auth_response.txt | jq -r .auth.client_token)
echo ${VAULT_TOKEN}

# Finally, retrieve secret using Vault token
curl \
     --header "X-Vault-Token: ${VAULT_TOKEN}" \
     ${VAULT_ADDR}/v1/${SECRET_KEY}
```


### Cleanup 

When done delete the deployment and go back to the parent directory:

```
kubectl delete -f deployment.yaml
cd ..
```

## Next Steps

Next we will [run a sidecar example](./4-deploy-sidecar.md).




