tasklist /fi "IMAGENAME eq badvpn-tun2socks.exe" /fo csv 2>NUL | find /I "badvpn-tun2socks.exe">NUL
if "%ERRORLEVEL%"=="0" taskkill /im badvpn-tun2socks.exe /t /f
start cmd /c route add 0.0.0.0 mask 0.0.0.0 10.0.0.2 metric 6
start /min cmd /k badvpn-tun2socks.exe --tundev "tap0901:Ethernet 2:10.0.0.1:10.0.0.0:255.255.255.0" --netif-ipaddr 10.0.0.2 --netif-netmask 255.255.255.0 --socks-server-addr 192.168.43.1:7100 --udpgw-remote-server-addr 127.0.0.1:7100 --loglevel 0 ^& exit
sleep 4
start cmd /c route add 0.0.0.0 mask 0.0.0.0 10.0.0.2 metric 6