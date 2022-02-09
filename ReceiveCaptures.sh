#!/usr/bin/env bash
#
# Script name: ReceiveCaptures.sh
# Description: Send image files that appear in a directory to the system clipboard.
# Dependencies: xclip, inotifywait (inotify-tools)
# Github: https://github.com/reptm001/KDEConnect-Send-Image-to-Clipboard
# Author: Michael Repton

# pipefail setup
set -Eeuo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat << EOF # remove the space between << and EOF, this is due to web plugin issue
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-r] [-d DIRECTORY]

Send image files that appear in a DIRECTORY to the system clipboard.

Where a DIRECTORY is not specified, the script directory will be used.
Used in conjunction with the 'SendCaptures.sh' script on the sending DEVICE.

Example: $(basename "${BASH_SOURCE[0]}") -d '/home/username/screenshots/' -r

Available options:

-h, --help          Print this help and exit
-v, --verbose       Print script debug info
-r, --remove-file   Remove image after receiving it
-d, --dir           Specify directory to monitor and receive from
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

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -r | --remove-file) remove_file=1 ;; # remove file after receiving
    -d | --dir) # specify directory
      notify_dir="${2-}"
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

### Monitor directory for new files
## Send file to system clipboard if it is of type image/png
## Delete file if specified in script flags
inotifywait -m $notify_dir -e create -e moved_to --format "%w%f"|
    while read filepath
    do
        msg ""
        file=${filepath##*/}
        dir="${filepath%/*}/"
        sleep 1
        msg "The file '$file' appeared in directory '$dir'"
        file_size=$(stat -c%s $filepath)
        if [ $file_size -gt 100 ]
        then
            if file -b "$filepath" | grep -qE 'PNG'
            then
                xclip -selection clipboard -t image/png -i $filepath
                msg "File '$file' added to clipboard."
                if [ "$remove_file" == "1" ]
                then
                    rm $filepath
                    msg "File '$file' deleted."
                fi
            else
                msg "File '$file' not of type image/png, skipping.."
            fi
        else
            msg "File '$file' smaller than 100 bytes, skipping.."
        fi
    done
