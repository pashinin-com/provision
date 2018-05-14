.. code-block:: bash

   git clone git@github.com:pashinin-com/provision.git
   cd provision
   make  # installs ansible

Note 1: remove `-i hosts` to use default `/etc/ansible/hosts` inventry
file.

Note 2: remove `--check` to actually do the stuff.

Note 3: add `--tags "consul"` to run only tasks marked by "consul" tag.


.. code-block:: bash

   # Install Consul at all "consul" hosts (defined in inventory)
   ansible-playbook consul.yml -i hosts -f 10 --check

   # Install Consul only at one host
   ansible-playbook consul.yml -i hosts --limit '10.254.239.2' -f 10 --check

   # Check Consul (will list alive and failed nodes)
   consul members


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
