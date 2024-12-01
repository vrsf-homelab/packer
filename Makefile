init:
	@echo ">> Initializing Packer ..."
	@cd debian; packer init .

build: build-debian-alpha build-debian-beta build-debian-tango
	@echo ">> Starting build Debian ..."

build-debian-alpha: init
	@echo ">> Starting build Debian on 'alpha'"
	@cd debian; packer build -var 'proxmox_node=alpha' -var-file variables.pkrvars.hcl -var-file ../root.pkrvars.hcl .

build-debian-beta: init
	@echo ">> Starting build Debian on 'beta'"
	@cd debian; packer build -var 'proxmox_node=beta' -var-file variables.pkrvars.hcl -var-file ../root.pkrvars.hcl .

# build-debian-charlie: init
# 	@echo ">> Starting build Debian on 'charlie'"
# 	@cd debian; packer build -var 'proxmox_node=charlie' -var-file variables.pkrvars.hcl -var-file ../root.pkrvars.hcl .

build-debian-tango: init
	@echo ">> Starting build Debian on 'tango'"
	@cd debian; packer build -var 'proxmox_node=tango' -var-file variables.pkrvars.hcl -var-file ../root.pkrvars.hcl .
