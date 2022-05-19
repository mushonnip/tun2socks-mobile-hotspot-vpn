#!/bin/sh
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

setup_tap_and_route(){
    sudo ifconfig tun0 10.0.0.1 netmask 255.255.255.0
    if route | grep tun0; then
        sudo route add default gw 10.0.0.2 metric 6
    fi
}

run_badvpn(){
    sudo badvpn-tun2socks --tundev tun0 --netif-ipaddr 10.0.0.2 --netif-netmask 255.255.255.0 --socks-server-addr 192.168.43.1:7100 --udpgw-remote-server-addr 127.0.0.1:7100 --loglevel 0 &
    setup_tap_and_route
    printf "${GREEN}badvpn-tun2socks is running${NC}\n"
}

if pidof badvpn-tun2socks; then
    printf "${YELLOW}badvpn-tun2socks is already running, killing it...${NC}\n"
    sudo route del -net 0.0.0.0 gw 198.18.0.1 netmask 0.0.0.0 dev tun0
    sudo route del -net 198.18.0.0 gw 0.0.0.0 netmask 255.254.0.0 dev tun0
    sudo ip link delete tun0
    sudo killall badvpn-tun2socks
fi

if sudo ip tuntap add dev tun0 mode tun user abu; then
   echo "tap device added"
fi

run_badvpn
