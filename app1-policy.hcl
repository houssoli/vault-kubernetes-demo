path "secret/creds" {
  capabilities = ["read"]
}

path "aws/creds/ec2" {
  capabilities = ["read"]
}

path "database/creds/readonly" {
  capabilities = ["read"]
}