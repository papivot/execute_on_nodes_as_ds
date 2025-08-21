#!/bin/bash
set -e
echo "Starting execution of install script"
echo "Copying required binaries and files to the host filesystem"
cp /host-install-files/* /host

/usr/bin/nsenter -a -t 1 chmod +x /tmp/install/install.sh
/usr/bin/nsenter -a -t 1 chmod +x /tmp/install/wait.sh

echo "Executing wait script for the node to become ready for script execution"
/usr/bin/nsenter -a -t 1 /tmp/install/wait.sh

echo "Executing script"
/usr/bin/nsenter -a -t 1 /tmp/install/install.sh

echo "Sleeping..."
while true;
do
	sleep 30
done
