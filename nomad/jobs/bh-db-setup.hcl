job "book-hub-db-setup" {
    datacenters = ["hc1"]
    region = "ru-ru"
    type = "batch"
    namespace = "book-hub"

    parameterized {
        payload = "forbidden"
        meta_required = ["db_name"]
        meta_optional = ["run_param1", "run_param2", "run_param3"]
    }
    meta {
        run_param1 = "drop"
        run_param2 = "to=10"
        run_param3 = "mock1"
    }
    ui {
        description = "Batch job to run `db-migration`"
        link {
            label = "GitHub"
            url   = "https://github.com/wi1sp/pmmt"
        }
    }

    task "sync-migrations" {
        env {
            ENV_FILE = ".env.secret"
        }
        driver = "docker"

        config {
            force_pull = true
            entrypoint = [
                "python", "-m", "migration_tool.cli", 
                "--name", "${NOMAD_META_db_name}", 
                "--${NOMAD_META_run_param1}",
                "--${NOMAD_META_run_param2}",
                "--${NOMAD_META_run_param3}"
            ]
            image = "wi1sp/pmmt"
            volumes = [
			    "local/secret.env:/.env.secret",
			    "local/config.yaml:/config.yaml",
            ]

            auth {
                username = "wi1sp"
                password = "${DOCKER_PAT}"
            }
        }
        template {
            data = <<EOF
{{ with nomadVar "book-hub/secret/pat" }}
DOCKER_PAT="{{ .DOCKER_PAT }}"
GH_PAT="{{ .GH_PAT }}"
{{ end }}
            EOF
            change_mode = "noop"
            destination = "local/secret.pat.env"
            env = true
        }
        template {
            data = <<EOF
sources:
  - id: GH_BH_API
    type: github
    branch: master
    repo: book-hub-api
    repo_owner: book-hub-umsp
    path: migrations

db:
  - id: BH_API_DB
    type: psql
    source: GH_BH_API
    name: books_hub
            EOF
            change_mode = "noop"
            destination = "local/config.yaml"
        }
        template {
            data = <<EOF
CONFIG_PATH="config.yaml"
{{ with nomadVar "book-hub/secret/db" }}
BH_API_DB_HOST="{{ .DB_ADDR }}"
BH_API_DB_PORT={{ .DB_PORT }}
BH_API_DB_USER="{{ .DB_USER }}"
BH_API_DB_USER_PASSWORD="{{ .DB_PASS }}"
{{ end }}
{{ with nomadVar "book-hub/secret/pat" }}
GH_BH_API_PAT="{{ .GH_PAT }}"
{{ end }}
            EOF
            change_mode = "noop"
            destination = "local/secret.env"
        }
    }
}

