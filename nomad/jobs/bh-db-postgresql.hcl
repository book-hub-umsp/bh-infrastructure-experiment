variable "ROOT_PASS" {
  type        = string
  description = "Password of root use in db."
}
variable "MASTER_PASS" {
  type        = string
  description = "Master password for pgadmin."
}


job "bockhub-db" {
    datacenters = ["hc1"]
    region = "ru-ru"
    type = "service"

    group "db-util" {
        count = 1

		network {
            port "ui" {
                static = "5052"
                to = "80"
            }
        }

        task "pgadmin4" {
            driver = "docker"
            config {
				force_pull = true
                image = "dpage/pgadmin4:7.2"
                ports = ["ui"]
                volumes = [
					"local/servers.json:/servers.json",
					"local/servers.passfile:/root/.pgpass"
                ]
            }
            template {
                perms = "600"
                change_mode = "noop"
                destination = "local/servers.passfile"
                data = <<EOF
        		{{ range nomadService "bh-db-postgresql" }}
{{ .Address }}:{{ .Port }}:postgres:root:${var.ROOT_PASS}
				{{ end }}
        		EOF
            }
      		template {
        		change_mode = "noop"
        		destination = "local/servers.json"
        		data = <<EOF
				{{ range nomadService "postgresql" }}
{
	"Servers": {
		"1": {
			"Name": "Book Hub DB",
			"Username": "root",
			"Group": "DB",
			"Port": {{ .Port }},
			"PassFile": "/root/.pgpass",
			"Host": "{{ .Address }}",
			"SSLMode": "disable",
			"MaintenanceDB": "postgres"
		}
	}
}
				{{ end }}
				EOF
      		}
            env {
                PGADMIN_DEFAULT_EMAIL="mail@mail.com"
				PGADMIN_DEFAULT_PASSWORD="${var.MASTER_PASS}"
				PGADMIN_CONFIG_SERVER_MODE="False"
				PGADMIN_CONFIG_ENHANCED_COOKIE_PROTECTION="False"
        		PGADMIN_SERVER_JSON_FILE="/servers.json"
            }

            logs {
                max_files     = 1
                max_file_size = 15
            }

            resources {
                cpu = 1000
                memory = 512
            }
            service {
				provider = "nomad"
                name = "bh-db-pgadmin"
                # tags = [ "urlprefix-/pgadmin strip=/pgadmin"]
                port = "ui"

                check {
                    name     = "alive"
                    type     = "tcp"
                    interval = "10s"
                    timeout  = "20s"
                }
            }
        }
        restart {
            attempts = 10
            interval = "5m"
            delay = "25s"
            mode = "delay"
        }

    }

    group "db" {

    	count = 1
		volume "pg_data" {
      		type      = "host"
			read_only = false
      		source    = "db_data"
    	}
		network {
            port "db" {
                static = "5051"
                to = "5432"
            }
        }
		task "postgres" {
			driver = "docker"

			volume_mount {
				volume      = "pg_data"
				destination = "/var/lib/postgresql/data"
				read_only   = false
			}
			# csi_plugin {
			# 	id                     = "bh-main-db"
			# 	type                   = "monolith"
			# 	mount_dir              = "/var/lib/postgresql/data"
			# 	# stage_publish_base_dir = "/local/csi"
			# }

			config {
				image = "postgres:16"
				ports = ["db"]
			}
			env {
				POSTGRES_USER="root"
				POSTGRES_PASSWORD="${var.ROOT_PASS}"
				PGDATA="/var/lib/postgresql/data/pgdata"
			}
			resources {
				cpu = 2000
				memory = 1024
			}
			service {
				name = "bh-db-postgresql"
				provider = "nomad"
				# tags = ["postgres for vault"]
				port = "db"
			}	
		}
		
		restart {
			attempts = 10
			interval = "5m"
			delay = "25s"
			mode = "delay"
		}
	}
  	update {
		max_parallel = 1
		min_healthy_time = "5s"
		healthy_deadline = "3m"
		auto_revert = false
		canary = 0
  	}
}
