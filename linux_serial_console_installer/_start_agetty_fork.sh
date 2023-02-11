#!/bin/sh

set -o nounset

path="${1}"
shift
device="${1}"
echo "${path}" "${device}" | at now
