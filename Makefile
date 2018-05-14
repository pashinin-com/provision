prepare:
	which pip || sudo apt install -y python-pip
	which ansible || sudo -H pip install ansible -U
	which sshd || sudo apt -y install ssh
