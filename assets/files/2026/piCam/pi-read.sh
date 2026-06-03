#!/bin/bash
echo Doing sudo. Password for Sophia
sudo scp -i /Users/brisa/.ssh/id_rsa "pi-admin@ojo.local:$1" "$1"

