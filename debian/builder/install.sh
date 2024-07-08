#!/bin/bash
set -eo pipefail
shopt -s nullglob
shopt -s dotglob

#
# C O N F I G U R A T I O N
#


#
# H E L P E R   F U N C T I O N S
#
declare -i term_width=120

# Function: h1
# Description: Prints a heading with a border around it.
# Parameters:
#   - $1: The text to be displayed as the heading.
# Returns: None
h1() {
  declare border padding text
  border='\e[1;34m'"$(printf '=%.0s' $(seq 1 "$term_width"))"'\e[0m'
  padding="$(printf ' %.0s' $(seq 1 $(((term_width - $(wc -m <<<"$*")) / 2))))"
  text="\\e[1m$*\\e[0m"
  echo -e "$border"
  echo -e "${padding}${text}${padding}"
  echo -e "$border"
}

# Function: h2
# Description: Prints a formatted header with a yellow arrow (==>) followed by the provided message.
# Parameters:
#   - $*: The message to be displayed as the header.
# Returns: None
h2() {
  printf '\e[1;33m==>\e[37;1m %s\e[0m\n' "$*"
}

# Function: info
# Description: Prints a formatted message with the current date and the provided message.
# Parameters:
#   - $*: The message to be printed.
# Returns: None
info() {
  printf "\n%s %s\n\n" "$( date )" "$*" >&2;
}

# Function: required
# Description: Checks if a command is installed and exits with an error message if it is not.
# Parameters:
#   $1 - The command to check
# Returns:
#   None
required() {
  hash "${1}" 2>/dev/null || { echo >&2 "${1} is required but is not installed.  Aborting."; exit 1; }
}


# This line sets up a trap to handle the interruption of the script.
# When the script receives an interrupt signal (INT) or termination signal (TERM),
# it will print the current date and time, display a message indicating that the script was interrupted,
# and exit with a status code of 2.
trap 'echo $( date ) Script interrupted >&2; exit 2' INT TERM

h1 "Update package index"
apt-get -qq -y update
h1 "Install required packages"
apt-get install -qq -y git jq unzip gnupg2 curl wget vim htop net-tools iputils-ping dialog apt-utils

h1 "🔥🔥🔥🔥 Image prepare complete! 🔥🔥🔥🔥"
