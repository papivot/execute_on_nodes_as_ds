#!/bin/bash

cp /tmp/install.sh /host
cp /tmp/wait.sh /host

/usr/bin/nsenter -a -t 1 chmod +x /tmp/install/install.sh
/usr/bin/nsenter -a -t 1 chmod +x /tmp/install/wait.sh
/usr/bin/nsenter -a -t 1 /tmp/install/wait.sh
/usr/bin/nsenter -a -t 1 /tmp/install/install.sh
while true;
do
	sleep 30
done
