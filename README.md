# KDE Connect Send-Image-to-Clipboard

Send an image from one PC to another PC through **KDE Connect** and add to the receiver's clipboard. Uses **inotifywait** to monitor directory file changes.

This is done through two bash scripts, one running on the **sender** PC and another on the **receiver** PC.

**Example usage**: 

Viewing content on the **sender** PC, making notes on the **receiver** PC -> Take a screenshot on the **sender** PC -> Quickly paste it into a note-taking app on the **receiver** PC. 

*Note: This example requires additional configuration of KDE Connect and a screenshotting tool (instructions listed below)*

**Requirements**:

- Both PCs (**sender/receiver**) must be running **Linux** and **KDE Plasma** (*PC -> Mobile not currently supported*)
- Both PCs (**sender/receiver**) must be paired and available to one another through KDE Connect
- Image files must be of type image/PNG : ".png" (*Other file types not currently supported*)

## Dependencies

Since these scripts make use of the **KDE Connect** application, both PCs (**sender/receiver**) must be running the **KDE Plasma** graphical desktop environment.

**KDE Connect Send-Image-to-Clipboard** requires the following dependencies:

| Dependency | PC |
| ---------- | -- |
| kdeconnect-cli (KDEConnect) | (**sender/receiver**) |
| inotify-tools (inotifywait) | (**sender/receiver**) |
| xclip | (**receiver**) |

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

![1](https://user-images.githubusercontent.com/7481414/153094519-76f1ee46-3c4e-43b2-998e-11a604e91ee4.png)

2) Select the **sender** PC from the left panel (device must be configured and connected) -> press **"Plugin Settings"**

![2](https://user-images.githubusercontent.com/7481414/153094574-c2167cc4-1f65-4115-96b8-3df236bcd55b.png)

3) Press the settings cog for **"Share and receive"**

![3](https://user-images.githubusercontent.com/7481414/153090276-543dbcf5-ca4e-4afc-a657-769b817ed6e1.png)

4) Enter the `/directory/to/receive/from/` into the input field -> hit **"Apply"**

![4](https://user-images.githubusercontent.com/7481414/153090292-2ae0852e-4bad-406f-a280-3281b86c7c14.png)

## Usage

### Sender

```
$ ./SendCaptures.sh --help
Usage: SendCaptures.sh [-h] [-v] [-r] [-d DIRECTORY] [-n DEVICE_NAME] [-c COMMAND_NAME]

Send image files that appear in a DIRECTORY to a DEVICE through KDE Connect.

Where a DIRECTORY   is not specified, the script directory will be used.
Where a DEVICE_NAME is not specified, the script will display a list of available devices to choose from.
Used in conjunction with the 'ReceiveCaptures.sh' script on the recieving DEVICE.

Example: SendCaptures.sh -r -d '/home/user/screenshots/' -n 'Desktop-PC'

Available options:

-h, --help          Print this help and exit
-v, --verbose       Print script debug info
-r, --remove-file   Remove image after sending it
-d, --dir           Specify directory to monitor and send from
-n, --device        Specify name of device to send to
-c, --command       Run remote command on device with given config name
```

### Receiver

```
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

## Troubleshooting

### `SendCaptures.sh` : incorrectly skipping files that are of type image/PNG

This may be a result of the script sending the image through kdeconnect-cli before it has been fully loaded into the filesystem.

To remedy this, increase the time for the script to wait before sending the image file on line 177:

```
177: sleep 1 -> 177: sleep 2
```

### `SendCaptures.sh` : KDE Connect hangs on 'Sending to *device-name*' or fails to send file

This may be the same issue as above.

## License
[GNU GPLv3](https://choosealicense.com/licenses/gpl-3.0/)
