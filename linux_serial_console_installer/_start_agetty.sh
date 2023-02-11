#!/bin/sh

set -o nounset

device="${1}"

while [ ! -h "/dev/${device}" ]
do
  #ls -alh "/dev/${device}"
  sleep 0.1
done

sudo systemctl start "serial-getty@${device}.service"
