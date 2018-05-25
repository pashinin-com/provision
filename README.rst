Documentation
=============

You can use this repo to install and configure Consul, HAProxy, Redis,
Dynomite and other stuff at several hosts.

Starting
--------

.. code-block:: bash

   git clone git@github.com:pashinin-com/provision.git
   cd provision
   make  # installs ansible

Note 1: remove `-i hosts` to use your default `/etc/ansible/hosts` inventry
file.

Note 2: remove `--check` to actually do the stuff.

Note 3: add `--tags "consul"` to run only tasks marked by "consul" tag.

Consul
------

Consul agent may run in one of two modes: client or server. There should
be 3-5 servers in a datacenter and agents running on all other
nodes (server is an agent too).

Downloads Consul and `consul-template`, installs it under
`/usr/local/bin/`, creates systemd scripts for `consul` and
`consul-template`, starts both.


.. code-block:: bash

   # Install Consul Agent on all "consul" hosts (defined in inventory)
   ansible-playbook consul.yml -i hosts --check

   # Install Consul Agent at one host only
   ansible-playbook consul.yml -i hosts --limit '10.254.239.4' --check

   # Install Consul Server at 1 hosts (use max 3-5 servers in 1 DC)
   ansible-playbook consul.yml -i hosts --limit '10.254.239.2' --extra-vars "mode=server" --check

   # Install Consul Server at 3 hosts (use max 3-5 servers in 1 DC)
   ansible-playbook consul.yml -i hosts --limit '10.254.239.1,10.254.239.2,10.254.239.3' --extra-vars "mode=server" --check

   # Check Consul (will list alive and failed nodes)
   consul members


..
   Redis
   -----

   .. code-block:: bash

      # Install Redis only at one host
      ansible-playbook redis.yml -i hosts --limit '10.254.239.2' -f 10 --check

Vault
-----

.. code-block:: bash

   # Install Vault only at one host
   ansible-playbook vault.yml -i hosts --limit '10.254.239.2' -f 10 --check


PostgreSQL
----------

Installs PostgreSQL 10 on Debian or Ubuntu.


.. code-block:: bash

   # Install PostgreSQL only at one host
   ansible-playbook postgresql.yml -i hosts --limit '10.254.239.2' -f 10 --check


Stolon
------

Downloads v0.10.0, extracts under /tmp/stolon/, copies bin files
`stolonctl`, `stolon-proxy`, `stolon-keeper`, `stolon-sentinel` under
`/usr/local/bin/`, installs systemd scripts for `proxy`, `keeper` and
`sentinel` and runs them.

.. code-block:: bash

   # Install
   ansible-playbook stolon.yml -i hosts --limit '10.254.239.2' -f 10 --check


Tarantool
---------

.. code-block:: bash

   # Install
   ansible-playbook tarantool.yml -i hosts -f 10 --check
   ansible-playbook tarantool.yml -i hosts --limit '10.254.239.2' -f 10 --check


Openresty
---------

Nginx + Lua + some stuff

.. code-block:: bash

   # Install
   ansible-playbook openresty.yml -i hosts --limit '10.254.239.2' -f 10 --check


Dynomite
--------

Note: I could install v0.6 in Ubuntu 16.04, but not in
Debian 9. Dynomite has an unsolved problem with OpenSSL 1.1.x branch.

Clones Dynomite git repo in `/usr/src/dynomite`, compiles, installs
under `/usr/bin/dynomite`, creates systemd scripts.

Listens on port 8102 on all addresses, connect to Redis running at
127.0.0.1:6379.

.. code-block:: bash

   # Install Dynomite at all "dynomite" hosts (defined in inventory)

   # Install Dynomite only at one host
   ansible-playbook dynomite.yml -i hosts --limit '10.254.239.2' --check

   # Test - terminal 1
   redis-cli -h 10.254.239.2 -p 8102
   # > SET test 123
   Terminal 2: Access redis on server B
   $ redis-cli -h 1.0.0.2 -p 8380
   $ > GET test
   # You should see output result: 123

..
   (cd ubuntu-setup; ansible-playbook -i hosts common.yml -f 10 --tags "site")
   (cd ubuntu-setup; ansible-playbook -i hosts common.yml -f 10 --tags "dynomite,haproxy")
   (cd ubuntu-setup; ansible-playbook -i hosts common.yml -f 10)

..
   students:
       (cd ubuntu-setup; ansible-playbook -i hosts students.yml -f 10)

..
   On server:

       bash <(wget -q https://raw.githubusercontent.com/pashinin/scripts/master/ubuntu-setup/server.sh -O -)


..
   ## From repo folder

   This will run `ansible-playbook ...` on all 3 machines:

       make provision


Examples
--------

.. code-block:: bash

   # example-my-desktop.yml - my Desktop (Debian 9)
   ansible-playbook example-my-desktop.yml -i hosts
