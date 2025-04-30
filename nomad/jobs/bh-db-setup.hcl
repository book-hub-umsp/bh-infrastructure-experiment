variable "ROOT_PASS" {
  type        = string
  description = "Password of root use in db."
}
variable "GH_PAT" {
  type        = string
  description = "Read token for github."
}
variable "DOCKER_PAT" {
  type        = string
  description = "Read token for docker hub."
}

job "bockhub-db-setup" {
    datacenters = ["hc1"]
    region = "ru-ru"
    type = "batch"

    parameterized {
        payload = "forbidden"
        meta_optional = ["run_param1", "run_param2", "run_param3"]
    }
    meta {
        run_param1 = "drop"
        run_param2 = "to=10"
        run_param3 = "mock1"
    }

    group "db-setup" {
        task "sync-migrations" {
            env {
                ENV_FILE = ".env.secret"
            }
            driver = "docker"

            config {
                force_pull = true
                # load = "./pmmt/pmmt.tar"
                entrypoint = [
                    "python", "-m", "migration_tool.cli", 
                    "--type", "postgresql", 
                    "--name", "books_hub", 
                    "--${NOMAD_META_run_param1}",
                    "--${NOMAD_META_run_param2}",
                    "--${NOMAD_META_run_param3}"
                ]
                image = "wi1sp/pmmt"

                volumes = [
					"local/secret.env:/.env.secret",
                ]

                auth {
                    username = "wi1sp"
                    password = "${var.DOCKER_PAT}"
                }
            }
            
            template {
                data = <<EOF
                {{ range nomadService "bh-db-postgresql" }}
DB_HOST="{{ .Address }}"
DB_PORT={{ .Port }}
DB_USER="root"
DB_USER_PASSWORD="${var.ROOT_PASS}"
GH_PAT="${var.GH_PAT}"
                {{ end }}
                EOF
                destination = "local/secret.env"
                env = true
            }
        }
        restart {
			interval = "5m"
			delay = "25s"
			mode = "delay"
		}
    }
}
