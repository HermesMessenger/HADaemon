#!/bin/bash
cd $(dirname $0)

Date=`date +"%Y-%m-%d %T"`
Version="1.1.0"
StatusFile="./.LastStatus"

echo "[DEBUG] Running HADaemon v$Version at $Date"

Token="fa7dbe7ea5ea4ed6ba6e00b31ca96394"
Domain="hermesmessenger.chat"

Hosts=("testing" "@" "www")
MyHosts=("server1" "db1")

if !(( ${#Hosts} && ${#MyHosts} )); then
    echo -e "[ERROR] The DNS hosts are unset, please edit this script and set them."
    exit 1
fi

DomainIP=$(host $Domain | awk '/has address/ { print $4 ; exit }')
MyIP=$(host ${MyHosts[0]}.$Domain | awk '/has address/ { print $4 ; exit }')

if [ $DomainIP == $MyIP ] ; then

    echo -e "[DEBUG] This server is currently active, no need to do anything"
    echo '0' > $StatusFile

else
    echo -e "[DEBUG] This server is not currently active, checking if active server is up..."

    curl -sL -w "%{http_code}\n" $Domain -o /dev/null &> /dev/null

    if [ $? == 0 ] ; then
        echo -e "[DEBUG] Active server is up, no need to do anything. " # TODO: Check active server's priority
        echo '1' > $StatusFile

    else
        echo -e "[DEBUG] Active server is down, updating DNS entries to this server"

        echo '0' > $StatusFile

        len=${#Hosts[@]}
        for (( i=0; i<${len}; i++ )); do
            echo url="https://dynamicdns.park-your-domain.com/update?domain=$Domain&host=${Hosts[$i]}&password=$Token" | curl -K - &> /dev/null
            echo "        -  Updated domain $((i + 1))/$len: ${Hosts[$i]}.$Domain"
        done

        LastStatus=$(cat $StatusFile)
        if [ "$LastStatus" != "2" ]; then 
            ./Telegram.sh "[HADaemon] Active server is down."
        fi

    fi
fi

echo -e "\n[DEBUG] Updating this server's DNS in case it's changed..."

len=${#MyHosts[@]}
for (( i=0; i<${len}; i++ )); do
    echo url="https://dynamicdns.park-your-domain.com/update?domain=$Domain&host=${MyHosts[$i]}&password=$Token" | curl -K - &> /dev/null
    echo "        -  Updated domain $((i + 1))/$len: ${MyHosts[$i]}.$Domain"
done

echo -e "\n[DEBUG] All done."
