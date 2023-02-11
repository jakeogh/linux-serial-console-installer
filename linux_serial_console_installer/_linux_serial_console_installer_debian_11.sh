#!/bin/bash

cat /etc/issue
grep "Debian GNU/Linux 11" /etc/issue > /dev/null || { echo "This script requires Debian 11" ; exit 1 ; }
#set -x

PATH="/home/${USER}/.local/bin:${PATH}"
export PATH=${PATH}

module_path=$(python3 << EOF
from importlib import resources
with resources.path('linux_serial_console_installer', '_linux_serial_console_installer_debian_11.sh') as rp:
    print(rp.parent.as_posix())
EOF
)

echo "${module_path}"

#linux_gpib_repo="${module_path}/linux-gpib"
#test -d "${linux_gpib_repo}" || { echo "${linux_gpib_repo} is not a directory. Exiting." ; exit 1 ; }

sudo apt install at -y --no-install-recommends

test -f /etc/udev/rules.d/99-com.rules.original || { sudo cp /etc/udev/rules.d/99-com.rules /etc/udev/rules.d/99-com.rules.original || exit 1 ; }

echo -n -e "\nPress ENTER when the USB device that you want an automatic linux console to be created on is connected: "
read -s
echo -n -e "\r"
echo -n -e "                                                "
echo -n -e "\r"
cmd=$(lsusb)
echo "${cmd}" | nl
echo -n -e "\nEnter line # you want to create a persistent login console on: "
read line_num
#echo "${line_num}"
line=$(echo "${cmd}" | head -n $(("${line_num}")) | tail -n 1)
#echo "${line}"
usb_id=$(echo "${line}" | cut -d ' ' -f 6)
#echo "${usb_id}"
vendor=$(echo "${usb_id}" | cut -d ':' -f 1)
product=$(echo "${usb_id}" | cut -d ':' -f 2)
#echo "${vendor}"
#echo "${product}"

device="ttyUSB_${vendor}_${product}_console"
udev_rule="KERNEL==\"ttyUSB[0-9]*\", ATTRS{idVendor}==\"${vendor}\", ATTRS{idProduct}==\"${product}\", SYMLINK+=\"${device}\""
echo ${udev_rule}
udev_rule_run="KERNEL==\"ttyUSB[0-9]*\", ATTRS{idVendor}==\"${vendor}\", ATTRS{idProduct}==\"${product}\", RUN+=\"${module_path}/_start_agetty_fork.sh ${module_path}/_start_agetty.sh ${device}\""
echo ${udev_rule_run}

echo -n "Press Enter to write the above udev rule: "
read

grep "${udev_rule}" /etc/udev/rules.d/99-com.rules && { echo "ERROR: rule already exists in /etc/udev/rules.d/99-com.rules. Exiting." ; exit 1 ; }
cat << EOF | sudo tee -a /etc/udev/rules.d/99-com.rules
${udev_rule}
${udev_rule_run}
EOF

# by default, systemd causes the gui to not load if a service fails to start. It's not great.
#sudo systemctl enable "serial-getty@ttyUSB_${device}_console.service"

echo "Debian 11 linux-serial-console-installer install completed OK, A REBOOT IS REQUIRED."
