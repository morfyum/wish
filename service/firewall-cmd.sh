#!/bin/bash
echo "Ports and services are not added permanently. If you restart the firewall, you will need to run this script again."
sudo firewall-cmd --add-service=samba
sudo firewall-cmd --add-port=445/tcp
sudo firewall-cmd --add-port=139/tcp
firewall-cmd --list-all
