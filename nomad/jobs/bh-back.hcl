job "book-hub-backend" {
    ui {
        description = "A job for `backend` services of **[BockHub project](https://github.com/book-hub-umsp)**"
        link {
            label = "GitHub"
            url   = "https://github.com/book-hub-umsp/book-hub-api"
        }
    }

    datacenters = ["hc1"]
    region = "global"

    type = "service"
    namespace = "default"
    group "backend" {
        count = 1

        network {
            port "http-main" {
                static = "5001"
                to = "8080"
            }
        }
        service {
            name = "bh-back-main-api-ru-bookhub"
            provider = "consul"
            tags = [
                "traefik.enable=true",
				"traefik.http.routers.bh-back-main-api-ru-bookhub.entrypoints=websecure", 
  				"traefik.http.routers.bh-back-main-api-ru-bookhub.rule=Host(`bh-back-main-api-ru-bookhub.service.consul`)",
                "traefik.http.routers.bh-back-main-api-ru-bookhub.tls=true",
                "traefik.http.routers.bh-back-main-api-ru-bookhub.tls.certresolver=le"
            ]
            port = "http-main"
        }
        task "main-api" {
            driver = "docker"

            config {
                force_pull=true
                image = "ghcr.io/book-hub-umsp/book-hub-api:${MAIN_API_VERSION}"
                ports = ["http-main"]
            }
            template {
                data = <<EOF
{{ with nomadVar "book-hub/secret/db" }}
ConnectionStrings__DefaultConnection="Host={{ .DB_ADDR }};Port={{ .DB_PORT }};Database=books_hub;Username={{ .DB_USER }};Password={{ .DB_PASS }};"
TestConfig__Content="Nomad settings"
{{ end }}
                EOF
                change_mode = "noop"
                destination = "local/secret.env"
                env = true
            }
            template {
                data = <<EOF
{{ with nomadVar "book-hub/meta/version" }}
MAIN_API_VERSION="{{ .MAIN_API_VERSION }}"
{{ end }}
                EOF
                change_mode = "noop"
                destination = "local/version.env"
                env = true
            }
            resources {
		        cpu = 500
			    memory = 512
		    }
        }
        restart {
			interval = "5m"
			delay = "25s"
			mode = "delay"
		}
    }
}
