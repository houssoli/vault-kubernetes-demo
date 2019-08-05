## K8S Vault [DRAFT]
This is a guide for deploying a dev vault node in Kubernetes. 

### Export environment variables
Set the Vault version, Namespace and Service account
```
export VAULT_VERSION="1.2.0"
export ns="default"
export sa="default"
```

### Write the dev vault deployment specification
```
cat <<EOF > dev-vault.yaml
apiVersion: apps/v1beta1
kind: Deployment 
metadata:
  name: dev-vault
  namespace: "${ns}"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vault
      name: dev-vault
  template:
    metadata:
      labels:
        app: vault
        name: dev-vault
    spec:
      serviceAccountName: "${sa}"
      containers:
        - name: vault 
          image: "vault:${VAULT_VERSION}"
          imagePullPolicy: IfNotPresent
          env:
            - name: VAULT_DEV_ROOT_TOKEN_ID
              value: "root"
          securityContext:
            capabilities:
              add:
                - IPC_LOCK 
EOF

# Create the deployment
kubectl apply -f dev-vault.yaml
```

### Write the vault service specification
We are creating a service called vault of type clusterIP which can be used for internal service discovery. 
```
cat <<EOF > vault-svc.yaml
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: vault
  name: vault
  namespace: "${ns}"
spec:
  type: clusterIP
  selector:
    name: dev-vault
    app: vault
  ports:
  - port: 8200
    protocol: TCP
    targetPort: 8200
EOF

# Create the service
kubectl apply -f vault-svc.yaml 
```

