#!/bin/bash
RED="\033[0;31m"
NO_COLOR="\033[0m"
GREEN="\033[32m\033[01m"
BLUE="\033[0;36m"
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
echo "export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
echo "等3秒……"
sleep 3
isRoot(){
  if [[ "$EUID" -ne 0 ]]; then
    echo "false"
  else
    echo "true"
  fi
}
init_release(){
  if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
  if [[ $release = "ubuntu" || $release = "debian" ]]; then
    PM='apt'
  elif [[ $release = "centos" ]]; then
    PM='yum'
  else
    exit 1
  fi
  # PM='apt'
}
tools_install(){
  systemctl stop trojan
  nginx -s stop
  service v2ray start
  caddy -service stop
  if [ $PM = 'apt' ] ; then
    apt-get update
    apt-get install -y dnsutils wget unzip zip curl tar git nginx
    apt-get install -y certbot
    apt-get install -y cron
  elif [ $PM = 'yum' ]; then
    yum update -y
    yum -y install bind-utils wget unzip zip curl tar git nginx crontabs
    yum install -y epel-release
    yum install -y certbot
  fi
}
web_get(){
  rm -rf /var/www
  mkdir /var/www
  echo -e "下面提供了15个不同的伪装网站模板，按对应的数字进行安装，安装之前可以查看网站demo:
  ${GREEN}1. https://templated.co/intensify
  ${GREEN}2. https://templated.co/binary
  ${GREEN}3. https://templated.co/retrospect
  ${GREEN}4. https://templated.co/spatial
  ${GREEN}5. https://templated.co/monochromed
  ${GREEN}6. https://templated.co/transit
  ${GREEN}7. https://templated.co/interphase
  ${GREEN}8. https://templated.co/ion
  ${GREEN}9. https://templated.co/solarize
  ${GREEN}10. https://templated.co/phaseshift
  ${GREEN}11. https://templated.co/horizons
  ${GREEN}12. https://templated.co/grassygrass
  ${GREEN}13. https://templated.co/breadth
  ${GREEN}14. https://templated.co/undeviating
  ${GREEN}15. https://templated.co/lorikeet${NO_COLOR}
  "
read -p "您输入你要安装的网站的数字:" aNum
case $aNum in
    1)wget -O web.zip --no-check-certificate https://templated.co/intensify/download
    ;;
    2)wget -O web.zip --no-check-certificate https://templated.co/binary/download
    ;;
    3)wget -O web.zip --no-check-certificate https://templated.co/retrospect/download
    ;;
    4)wget -O web.zip --no-check-certificate https://templated.co/spatial/download
    ;;
    5)wget -O web.zip --no-check-certificate https://templated.co/monochromed/download
    ;;
    6)wget -O web.zip --no-check-certificate https://templated.co/transit/download
    ;;
    7)wget -O web.zip --no-check-certificate https://templated.co/interphase/download
    ;;
    8)wget -O web.zip --no-check-certificate https://templated.co/ion/download
    ;;
    9)wget -O web.zip --no-check-certificate https://templated.co/solarize/download
    ;;
    10)wget -O web.zip --no-check-certificate https://templated.co/phaseshift/download
    ;;
    11)wget -O web.zip --no-check-certificate https://templated.co/horizons/download
    ;;
    12)wget -O web.zip --no-check-certificate https://templated.co/grassygrass/download
    ;;
    13)wget -O web.zip --no-check-certificate https://templated.co/breadth/download
    ;;
    14)wget -O web.zip --no-check-certificate https://templated.co/undeviating/download
    ;;
    15)wget -O web.zip --no-check-certificate https://templated.co/lorikeet/download
    ;;
    *)wget -O web.zip --no-check-certificate https://templated.co/intensify/download
    ;;
esac
    unzip -o -d /var/www web.zip
}
left_second(){
    seconds_left=10
    while [ $seconds_left -gt 0 ];do
      echo -n $seconds_left
      sleep 1
      seconds_left=$(($seconds_left - 1))
      echo -ne "\r     \r"
    done
}
 v2ray_install(){
   cp  /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
   service v2ray stop
   bash <(curl -L -s https://install.direct/go.sh)
 }
nginx_conf(){
  green "=========================================="
  green "       开始申请证书"
  green "=========================================="
  read -p "请输入您的域名：" domainname
  real_addr=`ping ${domainname} -c 1 | sed '1{s/[^(]*(//;s/).*//;q}'`
  local_addr=`curl ipv4.icanhazip.com`
  while [ "$real_addr" != "$local_addr" ]; do
     read -p "本机ip和绑定域名的IP不一致，请检查域名是否解析成功,并重新输入域名:" domainname
     real_addr=`ping ${domainname} -c 1 | sed '1{s/[^(]*(//;s/).*//;q}'`
     local_addr=`curl ipv4.icanhazip.com`
  done
  read -p "请输入您的邮箱：" emailname
  read -p "您输入的邮箱正确吗? [y/n]?" answer
    while [ $answer != "y" ]; do
	  read -p "请重新输入您的邮箱：" emailname
	  read -p "您输入的邮箱正确吗? [y/n]?" answer
  done
  certbot certonly --standalone -n --agree-tos --email $emailname -d $domainname
  cd /etc/letsencrypt/live/$domainname
  \cp fullchain.pem /etc/v2ray 2>&1 | tee /etc/v2ray/log
  \cp privkey.pem /etc/v2ray 2>&1 | tee /etc/v2ray/log
  curl -s -o /etc/nginx/conf.d/default.conf https://raw.githubusercontent.com/JeannieStudio/jeannie/master/v2ray_default.conf
  sed -i "s/mydomain.me/$domainname/g" /etc/nginx/conf.d/default.conf
}
genId(){
    id1=$(cat /proc/sys/kernel/random/uuid | md5sum |cut -c 1-8)
    id2=$(cat /proc/sys/kernel/random/uuid | md5sum |cut -c 1-4)
    id3=$(cat /proc/sys/kernel/random/uuid | md5sum |cut -c 1-4)
    id4=$(cat /proc/sys/kernel/random/uuid | md5sum |cut -c 1-4)
    id5=$(cat /proc/sys/kernel/random/uuid | md5sum |cut -c 1-12)
    id=$id1'-'$id2'-'$id3'-'$id4'-'$id5
    echo "$id"
}
v2ray_conf(){
  genId
  read -p  "已帮您随机产生一个uuid:
  $id，
  满意吗？（输入y表示不满意再生成一个，按其他键表示接受）" answer
  while [ $answer = "y" ]; do
      genId
      read -p  "uuid:$id，满意吗？（不满意输入y,按其他键表示接受）" answer
  done
  rm -f config.json
  curl -O https://raw.githubusercontent.com/JeannieStudio/jeannie/master/config.json
  sed -i "s/"b831381d-6324-4d53-ad4f-8cda48b30811"/$id/g" config.json
  \cp -rf config.json /etc/v2ray/config.json
}
CA_exist(){
  grep "cp: cannot stat" /etc/v2ray/log >/dev/null
    if [ $? -eq 0 ]; then
      FLAG="YES"
    else
      FLAG="NO"
    fi
}
check_CA(){
   CA_exist
   if [ $FLAG = "NO" ]; then
    end_time=$(echo | openssl s_client -servername $domainname -connect $domainname:443 2>/dev/null | openssl x509 -noout -dates |grep 'After'| awk -F '=' '{print $2}'| awk -F ' +' '{print $1,$2,$4 }' )
    while [ "${end_time}" = "" ]; do
        end_time=$(echo | openssl s_client -servername $domainname -connect $domainname:443 2>/dev/null | openssl x509 -noout -dates |grep 'After'| awk -F '=' '{print $2}'| awk -F ' +' '{print $1,$2,$4 }' )
    done
    end_times=$(date +%s -d "$end_time")
    now_time=$(date +%s -d "$(date | awk -F ' +'  '{print $2,$3,$6}')")
    RST=$(($((end_times-now_time))/(60*60*24)))
  fi
}
add_CA(){
  init_release
  if [ $PM = 'apt' ] ; then
    cron_job="30 3 1,7,21,28 * * /usr/bin/certbot-2 renew; /usr/sbin/nginx -s stop;/usr/sbin/nginx"
    ( crontab -l | grep -v "$cron_job"; echo "$cron_job" ) | crontab -
    service cron restart
  elif [ $PM = 'yum' ]; then
    echo "SHELL=/bin/bash
    30 3 1,7,21,28 * * /usr/bin/certbot-2 renew; /sbin/nginx -s stop;
    " > /var/spool/cron/root
    service crond reload
    service crond restart
  fi
}
main(){
   isRoot=$( isRoot )
  if [[ "${isRoot}" != "true" ]]; then
    echo -e "${RED_COLOR}error:${NO_COLOR}Please run this script as as root"
    exit 1
  else
  tools_install
  web_get
  v2ray_install
  nginx -s stop
  nginx_conf
  echo "睡一会儿……"
  left_second
  nginx
  systemctl enable nginx.service
  v2ray_conf
  echo "睡一会儿……"
  sleep 6
  service v2ray start
  check_CA
  add_CA
  CA_exist
  if [ $FLAG = "YES" ]; then
        echo -e "
$RED=======================================================
	      $RED    很遗憾，v2ray配置失败
$RED ======================================================
${RED}由于证书申请失败，无法科学上网，请重装或更换一个域名重新安装， 详情：https://letsencrypt.org/docs/rate-limits/
进一步验证证书申请情况，参考：https://www.ssllabs.com/ssltest/ $NO_COLOR" 2>&1 | tee info
  elif [ $FLAG = "NO" ]; then
  echo -e "
${GREEN}  ==================================================
	        ${GREEN}       恭喜你，v2ray安装和配置成功
${GREEN} ===================================================
$BLUE域名:        ${GREEN}${domainname}
$BLUE端口:        ${GREEN}443
${BLUE}UUID:       ${GREEN}${id}
${BLUE}alterId:    ${GREEN}64
${BLUE}混淆:       ${GREEN}websocket
${BLUE}路径：      ${GREEN}/ray
${BLUE}伪装网站：${GREEN}https://${domainname}
${GREEN}=========================================================
${BLUE}Windows、Macos客户端下载v2rayN：$GREEN https://github.com/2dust/v2rayN/releases
${BLUE}安卓客户端下载v2rayNG: ${GREEN}https://github.com/2dust/v2rayNG/releases
${BLUE}ios客户端请到应用商店下载：${GREEN}shadowrocket
${BLUE}关注jeannie studio：${GREEN}https://bit.ly/2X042ea
${GREEN}=========================================================
${GREEN}当前使用的域名： $domainname
${GREEN}证书有效期剩余天数:  ${RST}
${GREEN}不用担心，证书会自动更新${NO_COLOR}" 2>&1 | tee info
      fi
  touch /etc/motd
  cat info > /etc/motd
  fi
}
main
