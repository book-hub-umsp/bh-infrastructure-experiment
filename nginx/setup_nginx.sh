#!/bin/bash

# Установка Nginx
sudo apt update
sudo apt install nginx apache2-utils -y

# Создание конфигурационного файла
cat <<EOL | sudo tee /etc/nginx/conf.d/book-hub.conf
upstream backend {
        server 147.45.159.235:5001;
}

upstream postgres {
        server 147.45.159.235:5051;
}

upstream pgadmin {
        server 147.45.159.235:5052;
}

server {
      listen 80;
      server_name 147.45.159.235;

      location / {
          proxy_pass http://backend;
          proxy_set_header Host \$host;
          proxy_set_header X-Real-IP \$remote_addr;
          proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto \$scheme;
      }

      location /postgres {
          auth_basic "Restricted";
          auth_basic_user_file /etc/nginx/.htpassw;
          proxy_pass http://postgres;
          proxy_set_header Host \$host;
          proxy_set_header X-Real-IP \$remote_addr;
      }

      location /pgadmin {
          auth_basic "Restricted";
          auth_basic_user_file /etc/nginx/.htpassw;
          proxy_pass http://147.45.159.235:5052;
          proxy_set_header Host \$host;
          proxy_set_header X-Real-IP \$remote_addr;
      }
}
EOL

sudo nginx -t
sudo systemctl restart nginx
