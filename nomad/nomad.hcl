data_dir  = "/var/lib/nomad"

bind_addr = "0.0.0.0" # the default

datacenter = "hc1"
region = "ru-ru"

acl {
    enabled = true
}

ports {
    http = 4646
    rpc  = 4647
    serf = 4648
}

advertise {
    # Defaults to the first private IP address.
    http = "127.0.0.1"
    rpc  = "127.0.0.1"
    serf = "127.0.0.1:5648" # non-default ports may be specified
}

server {
    job_max_priority = 100
    job_default_priority = 50
    enabled          = true
    bootstrap_expect = 1
    encrypt = "OlMtEAkpUiEEqHhPJ68qXxPdAur15GhCcgCgeFsL1Aw="
}

client {
    enabled       = true
    host_volume "db_data" {
        path      = "/var/data/db"
        read_only = false
    }
}

plugin "raw_exec" {
    config {
        enabled = true
    }
}

# consul {
#   address = "1.2.3.4:8500"
# }