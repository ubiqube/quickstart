ui = true

listener "tcp" {
  address     = "0.0.0.0:8201"
  tls_disable = 1
}

storage "mysql" {
  username = "key_vault"
  password = "ErNK_5WnilVsObP"
  database = "key_vault"
  address = "msa-db"
}

api_addr = "http://127.0.0.1:8200"

disable_mlock = "true"
