#!/bin/bash
echo Doing sudo. Password for Sophia
sudo scp -i /Users/brisa/.ssh/id_rsa "$1" "pi-admin@ojo.local:$1"

