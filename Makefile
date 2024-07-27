init:
	@echo ">> Initializing Packer ..."
	@cd debian; packer init .

build: build-debian-crimson build-debian-emerald
	@echo ">> Starting build Debian ..."

build-debian-crimson: init
	@echo ">> Starting build Debian on 'crimson'"
	@cd debian; packer build -var 'proxmox_node=crimson' -var-file variables.pkrvars.hcl -var-file ../root.pkrvars.hcl .

build-debian-emerald: init
	@echo ">> Starting build Debian on 'emerald'"
	@cd debian; packer build -var 'proxmox_node=emerald' -var-file variables.pkrvars.hcl -var-file ../root.pkrvars.hcl .
