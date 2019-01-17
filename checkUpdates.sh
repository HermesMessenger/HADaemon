#!/bin/bash

Domain="hermesmessenger.duckdns.org"
Token=$1

DomainIP=$(host $Domain | awk '/has address/ { print $4 ; exit }')

ExternalIP=$(wget -q -O - "http://myexternalip.com/raw")

if [ $DomainIP = $ExternalIP ] ; then

    echo "This IP is running the server"

else
    echo "This IP is not running the server, checking if server is up..."
    
    ping -c1 -W1 -q $DomainIP &>/dev/null

    if [ $? == 0 ] ; then
        echo "Server is up, no need to do anything. "

    else
        echo "Server isn't up, setting domain IP address to this server"

    	echo url="https://www.duckdns.org/update?domains=$Domain&token=$Token&verbose=true" | curl -k -o ~/Scripts/DuckDNS.log -K - 

    fi

fi
