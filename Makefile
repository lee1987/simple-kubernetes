RELEASE := Simple-kubernetes

help:           ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

initial:        ## Initial and install kubernetes dependencies.
	ansible-playbook -i settings.ini ./initial.yml
	ansible-playbook -i settings.ini ./kube-dependencies.yml

worker:         ## Setup workers.
	ansible-playbook -i settings.ini ./workers.yml

master:         ## Setup master.
	ansible-playbook -i settings.ini ./master.yml
