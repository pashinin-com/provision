# consul port is 8500
# I use HAProxy on 8501 on localhost
storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault"
}


listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = 1
  # scheme = "http"
  # tls_cert_file = "/etc/certs/vault.crt"
  # tls_key_file  = "/etc/certs/vault.key"
}


cluster_name = "testcluster"


# Error reading secret/pashinin.com: Get
# https://127.0.0.1:8200/v1/secret/pashinin.com: http: server gave HTTP
# response to HTTPS client

# This error is fixed by setting VAULT_ADDR=http://127.0.0.1:8200
