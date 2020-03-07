RELEASE := Simple-kubernetes

.PHONY: help
help:           ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

initial:        ## Initial and install kubernetes dependencies
	ansible-playbook -i settings.ini ./initial.yml
	ansible-playbook -i settings.ini ./kube-dependencies.yml

worker:         ## Setup worker nodes
	ansible-playbook -i settings.ini ./workers.yml

master:         ## Setup master node
	ansible-playbook -i settings.ini ./master.yml
