#!/bin/bash

###   This script will nslookup an AWS Load balancer FQDN, grab the IPs and update the hosts file if required ###
### It's useful if you have a local host entry for a service and the AWS LB IPs keep changing

aws_lb_fqdn="some-fqdn.some-region.elb.amazonaws.com"   #the full fqdn of the AWS load balancer
target_service_fqdn="some-service.your.domain.com"   #the FQDN you want to add into hosts for that IP

#Find address and store for later
serviceip1=$(/usr/bin/nslookup $aws_lb_fqdn | awk 'FNR ==6 {print$2}')
serviceip2=$(/usr/bin/nslookup $aws_lb_fqdn | awk 'FNR ==8 {print$2}')
serviceip3=$(/usr/bin/nslookup $aws_lb_fqdn | awk 'FNR ==10 {print$2}')
# check whether the IP is in the hosts file
ip1_match="$(grep -n $serviceip1 /etc/hosts)"
ip2_match="$(grep -n $serviceip2 /etc/hosts)"
ip3_match="$(grep -n $serviceip3 /etc/hosts)"

#See if matching IP exists and do nothing if so

if [ ! -z "$ip1_match" ] || [ ! -z "$ip2_match" ] || [ ! -z "$ip3_match" ]
        then
        echo "Valid IP present"
else # Scrap records and update
        echo "Removing old entries"
        #Remove existing entries 
        remove_entry="$(grep "$target_service_fqdn" /etc/hosts)"
        sed -i "/$target_service_fqdn/d" /etc/hosts
        echo "Building new hosts entries"
        #Add new entries to hosts file
        echo "$serviceip1 $target_service_fqdn" >> /etc/hosts
        echo "$serviceip1 added"
        cat /etc/hosts
fi
