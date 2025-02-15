#!/usr/bin/env bash
##  Forked from: https://cynarski.dev/

set -eo pipefail
shopt -s nullglob
shopt -s dotglob


CONSUL_VERSION=1.20.1-1

########
###  H E L P E R S
######################
declare -i term_width=60

h1() {
  declare border padding text
  border='\e[1;34m'"$(printf '=%.0s' $(seq 1 "$term_width"))"'\e[0m'
  padding="$(printf ' %.0s' $(seq 1 $(((term_width - $(wc -m <<<"$*")) / 8))))"
  text="\\e[1m$*\\e[0m"
  echo -e "$border"
  echo -e "${padding}${text}${padding}"
  echo -e "$border"
}

h2() {
  printf '\e[1;33m==>\e[37;1m %s\e[0m\n' "$*"
}

# This line sets up a trap to handle the interruption of the script.
# When the script receives an interrupt signal (INT) or termination signal (TERM),
# it will print the current date and time, display a message indicating that the script was interrupted,
# and exit with a status code of 2.
trap 'echo $( date ) Script interrupted >&2; exit 2' INT TERM


h1 "Update package index & install required packages"
apt-get -qq -y update
apt-get install -qq -y git jq unzip gnupg2 curl wget vim htop net-tools iputils-ping dialog apt-utils


h1 "Install & register Consul service"
h2 "Installing Consul..."
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
apt-get -qq -y update
apt-get install -qq -y consul=$CONSUL_VERSION

h2 "Registering machine in Consul..."
systemctl enable consul-register.service

h1 "🔥🔥🔥🔥 Image has been prepared! 🔥🔥🔥🔥"
