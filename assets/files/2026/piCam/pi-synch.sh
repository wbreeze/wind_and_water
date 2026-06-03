#!/bin/bash
echo Doing sudo. Password for Sophia
sudo rsync -e "ssh -i /Users/brisa/.ssh/id_rsa" -rptv pi-admin@ojo.local:/home/pi-admin/Videos/Popa /Users/brisa/Desktop

