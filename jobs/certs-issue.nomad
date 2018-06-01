job "certs-issue" {
  datacenters = ["dc1"]

  # service - long running tasks (servers)
  # batch - small jobs (minutes/days)
  # system - long lived job on every eligible node (rolling deploys, service discovery)
  type = "batch"

  # periodic {
  #   cron             = "44 0 * * * *"

  #   # if this job should wait until previous instances of this job have completed
  #   prohibit_overlap = true
  #   time_zone = "Europe/Moscow"
  # }

  constraint {
    attribute = "${attr.unique.hostname}"
    value     = "balancer1"
  }

  group "certs" {
    count = 1

    restart {
      mode = "fail"  # fail, delay (default)
      interval = "1m"
      attempts = 1
      delay = "10s"  # minimum wait
    }

    task "issue-certs" {
      driver = "raw_exec"
      config {
        # acme.sh --staging --issue -d pashinin.com  -d '*.pashinin.com' --dns dns_nsupdate --dnssleep 2 --deploy --deploy-hook vault_cli
        # acme.sh --issue -d pashinin.com  -d '*.pashinin.com' --dns dns_nsupdate --dnssleep 2 --deploy --deploy-hook vault_cli

        # err:
        # It seems that '*.pashinin.com' is an IDN( Internationalized Domain Names), please install 'idn' command first
        # It seems that is an IDN( Internationalized Domain Names), please install 'idn' command first
        command = "/root/.acme.sh/acme.sh"
        # "--staging",
        args = [
          "--issue",
          "-d",
          "pashinin.com",
          "-d",
          "*.pashinin.com",
          "--dns",
          "dns_nsupdate",
          "--dnssleep",
          "2",
          # "--debug",
          # "2",
          # "--log-level",
          # "2",
          # "--deploy",
          # "--deploy-hook",
          # "vault_cli"
        ]
      }

      env {
        HOME = "/root"
        # ACME_VERSION = "2"
        VAULT_ADDR = "http://vault.service.consul:8200"
        VAULT_PREFIX="acme"
        LE_WORKING_DIR = "/root/.acme.sh"
        ROLE_ID="75151502-38c4-ffbf-1bc7-e5bc647c4368"
        BRANCH = 2
        NSUPDATE_KEY = "/etc/bind/keys/update.key"  # needed it when running using Nomad!
      }

      resources {
        cpu    = 100
        memory = 50
        disk = 0

        # network {
        #   mbits = 1
        # }
      }

      vault {
        policies = ["acme"]
      }
    }
  }
}
