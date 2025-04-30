variable "ROOT_PASS" {
  type        = string
  description = "Password of root use in db."
}
variable "main-api-version" {
    type = string
    default = "latest"
    description = "Version of main api service"
}

job "bockhub-backend" {
    datacenters = ["hc1"]
    region = "ru-ru"
    type = "service"
    
    group "backend" {
        count = 1

        network {
            port "http" {
                static = "5001"
                to = "8080"
            }
        }
        service {
            name = "bh-back-main-api"
            provider = "nomad"
            port = "http"
        }
        task "main-api" {
            driver = "docker"

            config {
                image = "ghcr.io/book-hub-umsp/book-hub-api:${var.main-api-version}"
                ports = ["http"]
                # volumes = [
				# 	# "local/appsettings.json:/app/appsettings.json",
                # ]
            }
            template {
                data = <<EOF
        		{{ range nomadService "bh-db-postgresql" }}
ConnectionStrings__DefaultConnection="Host={{ .Address }};Port={{ .Port }};Database=books_hub;Username=root;Password=${var.ROOT_PASS};"
TestConfig__Content="Nomad settings"
				{{ end }}
                EOF
                destination = "local/secret.env"
                env = true
            }
            resources {
		        cpu = 2000
			    memory = 1024
		    }
        }
        restart {
			interval = "5m"
			delay = "25s"
			mode = "delay"
		}
    }
}
