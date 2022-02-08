# KDE Connect Send-Image-to-Clipboard

Send an image from one PC to another PC through **KDE Connect** and add to the receiver's clipboard. Uses **inotifywait** to monitor directory file changes.

## Dependencies

Since these scripts make use of the **KDE Connect** application, both PCs (**sender/receiver**) must be running the **KDE Plasma** graphical desktop environment.

**KDE Connect Send-Image-to-Clipboard** requires the following dependencies:

| Dependency | PC |
| ---------- | -- |
| - kdeconnect-cli (KDEConnect) | (**sender/receiver**) |
| - inotify-tools (inotifywait) | (**sender/receiver**) |
| - xclip | (**receiver**) |

### Installing Dependencies

**Debian-based**

Sender

```bash
$ sudo apt update
$ sudo apt install kdeconnect inotify-tools
```

Receiver

```bash
$ sudo apt update
$ sudo apt install kdeconnect inotify-tools xclip
```

**Arch-based**

Sender

```bash
$ yay -Syu
$ yay -S kdeconnect inotify-tools
```

Receiver

```bash
$ yay -Syu
$ yay -S kdeconnect inotify-tools xclip
```

## Installation/Setup

### Sender

On the **sender** PC, grab the `SendCaptures.sh` script, and move it to the directory you wish to send image files from

```bash
$ git clone https://github.com/reptm001/KDEConnect-Send-Image-to-Clipboard
$ cd KDEConnect-Send-Image-to-Clipboard
$ cp SendCaptures.sh /directory/to/send/from/
```

For example,

```bash
$ cp SendCaptures.sh /home/reptm001/screenshots/
```

Make sure to give the `SendCaptures.sh` script the appropriate permissions

```bash
$ cd /directory/to/send/from/
$ sudo chmod +x SendCaptures.sh
```

***Optionally***, configure you're screenshotting tool to save to this directory. In the case of **flameshot**, bind a keyboard shortcut to the following:

```bash
$ flameshot gui --path /home/reptm001/screenshots/
```

### Receiver

On the **receiver** PC, grab the `ReceiveCaptures.sh` script, and move it to the directory you wish to receive image files from

```bash
$ git clone https://github.com/reptm001/KDEConnect-Send-Image-to-Clipboard
$ cd KDEConnect-Send-Image-to-Clipboard
$ cp ReceiveCaptures.sh /directory/to/receive/from/
```

For example,

```bash
$ cp ReceiveCaptures.sh /home/reptm001/screenshots/
```

Make sure to give the `ReceiveCaptures.sh` script the appropriate permissions

```bash
$ cd /directory/to/receive/from/
$ sudo chmod +x ReceiveCaptures.sh
```

***Optionally***, configure KDE Connect to save received files to this directory:

1) Launch **KDE Connect** from the Application Launcher

2) Select the **sender** PC from the left panel (device must be configured and connected) -> press **"Plugin Settings"**

3) Press the settings cog for **"Share and receive"**

4) Enter the `/directory/to/receive/from/` into the input field -> hit **"Apply"**

## Usage

### Sender

```bash
$ ./SendCaptures.sh --help
Usage: SendCaptures.sh [-h] [-v] [-r] [-d DIRECTORY] [-n DEVICE_NAME]

Send image files that appear in a DIRECTORY to a DEVICE through KDE Connect.

Where a DIRECTORY   is not specified, the script directory will be used.
Where a DEVICE_NAME is not specified, the script will display a list of available devices to choose from.
Used in conjunction with the 'ReceiveCaptures.sh' script on the recieving DEVICE.

Example: SendCaptures.sh -d '/home/user/screenshots/' -n 'Desktop-PC' -r

Available options:

-h, --help          Print this help and exit
-v, --verbose       Print script debug info
-r, --remove-file   Remove image after sending it
-d, --dir           Specify directory to monitor and send from
-n, --device        Specify name of device to send to
```

### Receiver

```bash
$ ./ReceiveCaptures.sh
Usage: ReceiveCaptures.sh [-h] [-v] [-r] [-d DIRECTORY]

Send image files that appear in a DIRECTORY to the system clipboard.

Where a DIRECTORY is not specified, the script directory will be used.
Used in conjunction with the 'SendCaptures.sh' script on the sending DEVICE.

Example: ReceiveCaptures.sh -d '/home/username/screenshots/' -r

Available options:

-h, --help          Print this help and exit
-v, --verbose       Print script debug info
-r, --remove-file   Remove image after receiving it
-d, --dir           Specify directory to monitor and receive from
```


## License
[GNU GPLv3](https://choosealicense.com/licenses/gpl-3.0/)
