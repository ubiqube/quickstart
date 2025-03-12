ui = true

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

storage "postgresql" {
  connection_url = "postgres://key_vault:ErNK_5WnilVsObP@msa-db:5432/key_vault?sslmode=disable"
}

api_addr = "http://127.0.0.1:8200"

disable_mlock = "true"