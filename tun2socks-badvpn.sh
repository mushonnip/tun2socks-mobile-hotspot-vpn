#!/bin/sh
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PROXY_IP=192.168.43.1
PROXY_PORT=7100

UDPGW_IP=127.0.0.1
UDPGW_PORT=7100

setup_tap_and_route(){
    sudo ifconfig tun0 10.0.0.1 netmask 255.255.255.0 > /dev/null 2>&1
    if route | grep tun0; then
        sudo route add default gw 10.0.0.2 metric 6 > /dev/null 2>&1
    fi
}

run_badvpn(){
    sudo badvpn-tun2socks --tundev tun0 --netif-ipaddr 10.0.0.2 --netif-netmask 255.255.255.0 --socks-server-addr $PROXY_IP:$PROXY_PORT --udpgw-remote-server-addr $UDPGW_IP:$UDPGW_PORT --loglevel 0 &
    setup_tap_and_route
    printf "${GREEN}badvpn-tun2socks is running${NC}\n"
}

# check if badvpn-tun2socks is running
if pidof badvpn-tun2socks > /dev/null 2>&1; then
    printf "${YELLOW}badvpn-tun2socks is already running, killing it...${NC}\n"
    sudo route del -net 0.0.0.0 gw 10.0.0.2 netmask 0.0.0.0 dev tun0
    sudo route del -net 10.0.0.0 gw 0.0.0.0 netmask 255.255.255.0 dev tun0
    sudo ip link delete tun0
    sudo killall badvpn-tun2socks
fi

# add tap interface
if sudo ip tuntap add dev tun0 mode tun user $(whoami); then
   echo "tap interface added"
fi

run_badvpn
