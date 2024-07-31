##################################
#### P R O V I S I O N E R
#######################
packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.8"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}


##############################
#### V A R I A B L E S
###################
variable "proxmox_api_password" {
  type      = string
  sensitive = true
}
variable "proxmox_api_user" {
  type = string
}
variable "proxmox_host" {
  type = string
}
variable "proxmox_node" {
  type = string
}
variable "iso_file" {
  type = string
}
variable "storage_type" {
  type    = string
  default = "local-lvm"
}


#########################
#### L O C A L S
##############
locals {
  storage_type = var.storage_type
  builder_dir = "/tmp/builder"

  ## Formatting template name
  ### `debian-12.5.0-amd64-netinst.iso` => `debian-12.5.0-amd64-YYYYMMDD`
  iso_name_fragments = split("-", basename(var.iso_file))
  iso_name_without_last = slice(local.iso_name_fragments, 0, length(local.iso_name_fragments) - 2)
  template_name = join("-", concat(local.iso_name_without_last, [formatdate("YYYYMMDD", timestamp())]))
}


#########################
#### S O U R C E
##############
source "proxmox-iso" "debian" {
  proxmox_url              = "https://${var.proxmox_host}/api2/json"
  insecure_skip_tls_verify = true
  username                 = var.proxmox_api_user
  password                 = var.proxmox_api_password

  template_description = "Built from ${basename(var.iso_file)} on ${formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())}"
  node                 = var.proxmox_node

  network_adapters {
    bridge   = "vmbr0"
    firewall = true
    model    = "virtio"
  }

  disks {
    disk_size    = "20G"
    format       = "raw"
    io_thread    = true
    storage_pool = local.storage_type
    type         = "scsi"
  }

  scsi_controller = "virtio-scsi-single"

  iso_file       = var.iso_file
  http_directory = "./"
  boot_wait      = "10s"
  boot_command   = ["<esc><wait>auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<enter>"]
  unmount_iso    = true

  cloud_init              = true
  cloud_init_storage_pool = var.storage_type

  vm_name  = local.template_name
  os       = "l26"
  memory   = 1024
  cores    = 1
  sockets  = "1"
  machine  = "q35"

  # Note: this password is needed by packer to run the file provisioner, but
  # once that is done - the password will be set to random one by cloud init.
  ssh_password = "packer"
  ssh_username = "root"
  ssh_timeout  = "30m"
}

build {
  sources = ["source.proxmox-iso.debian"]

  provisioner "shell" {
    inline = [
      "mkdir -p ${local.builder_dir}",
    ]
  }

  provisioner "file" {
    destination = "/etc/cloud/cloud.cfg"
    source      = "cloud.cfg"
  }

  provisioner "file" {
    destination = local.builder_dir
    source      = "builder/"
  }

  provisioner "shell" {
    execute_command = "id && echo 'root' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    inline          = [
      "cd ${local.builder_dir}",
      "chmod +x install.sh",
      "./install.sh",
      "sleep 1",
      "rm -rf ${local.builder_dir}",
    ]
  }
}
