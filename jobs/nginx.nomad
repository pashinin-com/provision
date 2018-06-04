job "nginx" {
  datacenters = ["dc1"]

  # service - long running tasks (servers)
  # batch - small jobs (minutes/days)
  # system - long lived job on every eligible node (rolling deploys, service discovery)
  type = "service"

  # periodic {
  #   cron             = "44 0 * * * *"

  #   # if this job should wait until previous instances of this job have completed
  #   prohibit_overlap = true
  #   time_zone = "Europe/Moscow"
  # }

  constraint {
    attribute = "${attr.unique.hostname}"
    # operator  = "!="
    value     = "desktop"
  }

  group "nginx" {
    count = 1

    restart {
      mode = "fail"  # fail, delay (default)
      interval = "1m"
      attempts = 1
      delay = "10s"  # minimum wait
    }

    task "openresty" {
      driver = "docker"
      config {
        image = "nginx"
        port_map {
          http = 80
        }
        port_map {
          https = 443
        }

        # A list of host_path:container_path strings to bind host paths
        # to container paths
        #
        # "/path/on/host:/path/in/container",
        # "relative/to/task:/also/in/container"
        volumes = [
          "custom/default.conf:/etc/nginx/conf.d/default.conf",
          "secret/fullchain.pem:/etc/nginx/ssl/fullchain.pem",
          "secret/cert.key:/etc/nginx/ssl/cert.key",
          "/usr/data/local2/src/front/dist:/local/data",
        ]
      }

      template {
        data = <<EOH
server {
    server_name    pashinin.com *.pashinin.com;
    listen         80 proxy_protocol;
    set_real_ip_from 10.254.239.4/32;
    real_ip_header proxy_protocol;

    # Redirect from an IP address to a domain name:
    if ($host ~* ^(89.179.240.127)$ ) {
        return 301 https://pashinin.com$request_uri;
    }
    return 301 https://$host$request_uri;
}

          server {
            #listen     80 proxy_protocol;
            set_real_ip_from 10.254.239.4/32;
            real_ip_header proxy_protocol;
            #listen 443 ssl;
            listen 443 ssl http2 proxy_protocol;

            #server_name nginx.service.consul;
            server_name	  pashinin.com *.pashinin.com;
            # note this is slightly wonky using the same file for
            # both the cert and key
            ssl_certificate /etc/nginx/ssl/fullchain.pem;
            ssl_certificate_key /etc/nginx/ssl/cert.key;

ssl_session_cache shared:le_nginx_SSL:1m;
ssl_session_timeout 1440m;

ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;

ssl_ciphers "ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS";


            # add_header Strict-Transport-Security max-age=15768000;
            # ssl_stapling on;

            location / {
              root /local/data/;
              index baumanka.html;
            }
          }
        EOH

        destination = "custom/default.conf"
      }

      # acme/pashinin.com/fullchain.pem
      template {
        data = <<EOH
{{ with secret "acme/pashinin.com/fullchain.pem" }}
{{ .Data.value }}
{{ end }}
EOH
        destination = "secret/fullchain.pem"
      }

      # acme/pashinin.com/cert.key
      template {
        data = <<EOH
{{ with secret "acme/pashinin.com/cert.key" }}
{{ .Data.value }}
{{ end }}
EOH
        destination = "secret/cert.key"
      }

      # consul kv put features/motd 'Good afternoon.'
      template {
        data = <<EOH
          {{ if keyExists "features/motd" }}
            {{ key "features/motd" }}
          {{ else }}
            Good morning.
          {{ end }}
        EOH

        destination = "local/data/index.html"
      }

      env {
        # VAULT_ADDR = "http://vault.service.consul:8200"
        # VAULT_PREFIX="acme"
        # LE_WORKING_DIR = "/root/.acme.sh"
        # ROLE_ID="75151502-38c4-ffbf-1bc7-e5bc647c4368"
      }

      resources {
        # cpu    = 100 # 100 = 100 MHz
        memory = 256 # 128 = 128 MB
        network {
          mbits = 10
          port "http" {
            static = "80"
          }
          port "https" {
            static = "443"
          }
        }
      }

      service {
        name = "nginx"
        tags = ["frontend","urlprefix-/nginx strip=/nginx"]
        port = "http"
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      vault {
        policies = ["acme"]
      }
    }
  }
}
