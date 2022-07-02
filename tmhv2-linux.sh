#!/bin/sh
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

#192.168.43.1
PROXY_IP=192.168.43.1
PROXY_PORT=10808

UDPGW_IP=127.0.0.1
UDPGW_PORT=7200

INTERFACE=wlp1s0

setup_tap_and_route(){
    sudo ip tuntap add mode tun dev tun0
    sudo ip addr add 198.18.0.1/15 dev tun0
    sudo ip link set dev tun0 up

    sudo ip route del default
    sudo ip route add default via 198.18.0.1 dev tun0 metric 1
    sudo ip route add default via $PROXY_IP dev $INTERFACE metric 10
}

kill_all(){
    sudo ip link delete tun0
    sudo killall tun2socks
    printf "${YELLOW}tun2socks killed...${NC}\n"
}

run_badvpn(){
    setup_tap_and_route
    sudo tun2socks -device tun0 -proxy socks5://$PROXY_IP:$PROXY_PORT -interface $INTERFACE -loglevel silent &
    printf "${GREEN}tun2socks is running${NC}\n"
}

if [[ $1 == "kill" ]]; then
    kill_all
    exit
fi

# check if badvpn-tun2socks is running
if pidof tun2socks > /dev/null 2>&1; then
    printf "${YELLOW}tun2socks is already running, killing it...${NC}\n"
    kill_all
fi
run_badvpn
