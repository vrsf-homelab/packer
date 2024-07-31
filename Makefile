init:
	@echo ">> Initializing Packer ..."
	@cd debian; packer init .

build: build-debian-alpha build-debian-beta
	@echo ">> Starting build Debian ..."

build-debian-alpha: init
	@echo ">> Starting build Debian on 'alpha'"
	@cd debian; packer build -var 'proxmox_node=alpha' -var-file variables.pkrvars.hcl -var-file ../root.pkrvars.hcl .

build-debian-beta: init
	@echo ">> Starting build Debian on 'beta'"
	@cd debian; packer build -var 'proxmox_node=beta' -var-file variables.pkrvars.hcl -var-file ../root.pkrvars.hcl .
