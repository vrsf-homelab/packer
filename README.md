# Packer

Packer files for building images for Proxmox like Debian, Ubuntu, Rocky, etc.

## Proxmox setup

### User & role preparation

```shell
PKR_ROLE_NAME=Packer
PKR_USERNAME=packer
PKR_PASSWORD=""

# Create role with a required permissions
pveum role add $PKR_ROLE_NAME -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate SDN.Use Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt"

# Create user
pveum user add $PKR_USERNAME@pve --password $PKR_PASSWORD

# Assign created role for user
pveum aclmod / -user $PKR_USERNAME@pve -role $PKR_ROLE_NAME
```
