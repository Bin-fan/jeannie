#!/bin/bash
RED="\033[0;31m"
NO_COLOR="\033[0m"
GREEN="\033[32m\033[01m"
BLUE="\033[0;36m"
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
domainname=$(cat /etc/domainname)
if [ -f "/usr/sbin/nginx" ]; then
    /usr/bin/certbot-2 renew
    sleep 2
    /usr/sbin/nginx -s stop
    sleep 2
    /usr/sbin/nginx
fi
end_time=$(echo | openssl s_client -servername $domainname -connect $domainname:443 2>/dev/null | openssl x509 -noout -dates |grep 'After'| awk -F '=' '{print $2}'| awk -F ' +' '{print $1,$2,$4 }' )
#while [ "${end_time}" = "" ]; do
#       end_time=$(echo | openssl s_client -servername $domainname -connect $domainname:443 2>/dev/null | openssl x509 -noout -dates |grep 'After'| awk -F '=' '{print $2}'| awk -F ' +' '{print $1,$2,$4 }' )
#done
end_times=$(date +%s -d "$end_time")
now_time=$(date +%s -d "$(date | awk -F ' +'  '{print $2,$3,$6}')")
RST=$(($((end_times-now_time))/(60*60*24)))
if [ "${end_time}" != ""  ]; then
    sed -i "/证书有效期剩余天数/c 证书有效期剩余天数:  $RST" /etc/motd
fi

