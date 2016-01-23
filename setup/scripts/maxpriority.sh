#!/bin/bash
#
# Script to set max nice/ionice and scheduling, run as root
#
if [[ ! -z "${1}" ]]
then
    PROC_ID=$(pgrep ${1})
else
    echo "NO PROCESS GIVEN!"
    exit 1
fi

renice -n -20 -p ${PROC_ID}
ionice -c 2 -n 0 -p ${PROC_ID}
