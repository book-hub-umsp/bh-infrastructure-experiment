job "book-hub-frontend" {
    datacenters = ["hc1"]
    region = "ru-ru"
    type = "service"
    namespace = "book-hub"

    ui {
        description = "A job for `frontend` services of **[BockHub project](https://github.com/book-hub-umsp)**"
        link {
            label = "GitHub"
            url   = "https://github.com/book-hub-umsp/book-hub-app"
        }
    }

    group "frontend" {
        count = 1

        network {
            port "http" {
                static = "5002"
                to = "3000"  
            }
        }
        service {
            name = "bh-front-main-app-ru-bookhub"
            provider = "consul"
            tags = [
                "traefik.enable=true",
				"traefik.http.routers.bh-front-main-app-ru-bookhub.entrypoints=websecure", 
  				"traefik.http.routers.bh-front-main-app-ru-bookhub.rule=Host(`bh-front-main-app-ru-bookhub.service.consul`)",
                "traefik.http.routers.bh-front-main-app-ru-bookhub.tls=true",
                "traefik.http.routers.bh-front-main-app-ru-bookhub.tls.certresolver=le"
            ]
            port = "http" 
        }
        task "main-app" {
            driver = "docker"

            config {
                image = "ghcr.io/book-hub-umsp/book-hub-app:${MAIN_APP_VERSION}"
                ports = ["http"]
                # volumes = [
				# 	# "local/appsettings.json:/app/appsettings.json",
                # ]
            }
            template { 
                data = <<EOF
{{ with nomadVar "book-hub/secret/auth" }}
GOOGLE_CLIENT_ID="{{ .GAC_ID }}"
GOOGLE_CLIENT_SECRET="{{ .GAC_SECRET }}"
NEXTAUTH_SECRET="{{ .NA_SECRET }}"
{{ end }}
{{- range service "bh-front-main-app-ru-bookhub" }}
NEXTAUTH_URL="http://{{ .Address }}:{{ .Port }}"
{{- end }}
                EOF
                change_mode = "restart"
                destination = "local/secret.env"
                env = true
            }
                        template {
                data = <<EOF
{{ with nomadVar "book-hub/meta/version" }}
MAIN_APP_VERSION="{{ .MAIN_APP_VERSION }}"
{{ end }}
                EOF
                change_mode = "noop"
                destination = "local/version.env"
                env = true
            }
            resources {
		        cpu = 500
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
