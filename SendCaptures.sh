#!/usr/bin/env bash
#
# Script name: SendCaptures.sh
# Description: Send image files that appear in a directory to a device through KDE Connect.
# Dependencies: kdeconnect-cli, inotifywait (inotify-tools)
# Github: https://github.com/reptm001/KDEConnect-Send-Image-to-Clipboard
# Author: Michael Repton

# pipefail setup
set -Eeuo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat << EOF # remove the space between << and EOF, this is due to web plugin issue
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-r] [-d DIRECTORY] [-n DEVICE_NAME]

Send image files that appear in a DIRECTORY to a DEVICE through KDE Connect.

Where a DIRECTORY   is not specified, the script directory will be used.
Where a DEVICE_NAME is not specified, the script will display a list of available devices to choose from.
Used in conjunction with the 'ReceiveCaptures.sh' script on the recieving DEVICE.

Example: $(basename "${BASH_SOURCE[0]}") -d '/home/user/screenshots/' -n 'Desktop-PC' -r

Available options:

-h, --help          Print this help and exit
-v, --verbose       Print script debug info
-r, --remove-file   Remove image after sending it
-d, --dir           Specify directory to monitor and send from
-n, --device        Specify name of device to send to
EOF
  exit
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  remove_file=0
  notify_dir=''
  device_name=''

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -r | --remove-file) remove_file=1 ;; # remove file after sending
    -d | --dir) # specify directory
      notify_dir="${2-}"
      shift
      ;;
    -n | --device) # specify device_name
      device_name="${2-}"
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  return 0
}

parse_params "$@"
setup_colors

### Directory to monitor
## If unspecified, use script dir
## If specified, ensure dir exists
if [ "$notify_dir" == "" ]
then
    notify_dir=$script_dir
else
    [ ! -d "$notify_dir" ] && msg "Error: Directory '$notify_dir' does not exist." && die ""
fi

### Device to send to
## If unspecified, present available devices to choose from
## If specified, ensure device can be connected to
if [ "$device_name" == "" ]
then
    msg "Searching for available (paired and reachable) KDE Connect devices.."
    loop=1
    while [ $loop == 1 ]
    do
        DEVLIST=$(kdeconnect-cli -a | cut -c 3-)
        set -o noglob
        IFS=$'\n' DEVS="$DEVLIST"
        set +o noglob
        msg "Select a device:"
        PS3=": "
        COLUMNS=1
        select choice in $DEVS "(Refresh devices)" "(Quit)"
        do
            case "$choice" in
                "(Refresh devices)")
                    break
                    ;;
                "(Quit)")
                    die ""
                    ;;
                "")
                    msg "Error: Select a valid option."
                    break
                    ;;
                *)
                    device_name=${choice%%:*}
                    msg ""
                    msg "Selected device: '$device_name'"
                    loop=0
                    break
                    ;;
            esac
        done
        msg ""
    done
else
    DEVLIST=$(kdeconnect-cli -a | cut -c 3-)
    set -o noglob
    IFS=$'\n' DEVS="$DEVLIST"
    set +o noglob
    device_found=0
    for DEV in $DEVS
    do
        if [ "${DEV%%:*}" == "$device_name" ]
        then
            device_found=1
        fi
    done
    if [ $device_found -eq 0 ]
    then
        msg "$DEVLIST"
        msg ""
        msg "Error: Device '$device_name' cannot be found through KDE Connect."
        msg "  (Check the name of the device and current KDE Connect configs for both systems)"
        die ""
    else
        msg ""
        msg "Selected device: '$device_name'"
        msg ""
    fi
fi

### Monitor directory for new files
## Send file to device if it is of type image/png
## Delete file if specified in script flags
msg "Directory to watch: '$notify_dir'"
inotifywait -m $notify_dir -e create -e moved_to --format "%w%f"|
    while read filepath
    do
        msg ""
        file=${filepath##*/}
        dir="${filepath%/*}/"
        sleep 1 # wait for file to be present in filesystem in its entirety
        msg "The file '$file' appeared in directory '$dir'"
        if file -b "$filepath" | grep -qE 'PNG'
        then
            msg "Sending file '$file' to '$device_name'.."
            kdeconnect-cli --share $filepath -n $device_name
            msg "File '$file' sent."
            if [ "$remove_file" == "1" ]
            then
                rm $filepath
                msg "File '$file' deleted."
            fi
        else
            msg "File '$file' not of type image/png, skipping.."
        fi
    done



