# oct/22/2020 15:40:44 by RouterOS 6.47.4
# software id = 
#
#
#
/interface bridge
add name=bridge1
/interface ethernet
set [ find default-name=ether2 ] disable-running-check=no name=CT
set [ find default-name=ether6 ] disable-running-check=no name=CU
set [ find default-name=ether5 ] disable-running-check=no name=ether1
set [ find default-name=ether4 ] disable-running-check=no name=ether2
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether1 ] disable-running-check=no name=\
    management-lan1
/interface vrrp
add interface=CT name=vrrp-ct1
add interface=CT name=vrrp-ct2 vrid=2
add interface=CU name=vrrp-cu1
add interface=CU name=vrrp-cu2 vrid=2
/interface pppoe-client
add disabled=no interface=vrrp-ct1 name=pppoe-out1-ct password={} user=\
    {}
add disabled=no interface=vrrp-ct2 name=pppoe-out2-ct password={} user=\
    {}
add disabled=no interface=vrrp-cu1 name=pppoe-out3-cu password={} user=\
    {}
add disabled=no interface=vrrp-cu2 name=pppoe-out4-cu password={} user=\
    {}
/interface list
add comment=defconf name=WAN
add comment=defconf name=LAN
/interface bridge port
add bridge=bridge1 interface=management-lan1
add bridge=bridge1 interface=ether1
add bridge=bridge1 interface=ether2
add bridge=bridge1 interface=ether3
/interface list member
add interface=CT list=WAN
add interface=CU list=WAN
add interface=pppoe-out1-ct list=WAN
add interface=pppoe-out2-ct list=WAN
add interface=pppoe-out3-cu list=WAN
add interface=pppoe-out4-cu list=WAN
add interface=bridge1 list=LAN
/ip address
add address=10.10.7.1/24 interface=bridge1 network=10.10.7.0
add address=192.168.0.1/24 interface=CT network=192.168.0.0
add address=192.168.0.1/24 interface=vrrp-ct1 network=192.168.0.0
add address=192.168.0.2/24 interface=vrrp-ct2 network=192.168.0.0
add address=192.168.1.1/24 interface=vrrp-cu1 network=192.168.1.0
add address=192.168.1.2/24 interface=vrrp-cu2 network=192.168.1.0
add address=192.168.1.0/24 interface=CU network=192.168.1.0
/ip dhcp-client
# DHCP client can not run on slave interface!
add disabled=no interface=management-lan1
/ip dns
set servers=223.5.5.5,114.114.114.114
/ip firewall address-list
# add address list start here
add address=1.0.1.0/24 list=dpbr-CT
add address=1.0.2.0/23 list=dpbr-CT
# add address list end here
/ip firewall filter
add action=accept chain=input comment="accept ping" protocol=icmp
add action=accept chain=input comment="accept established,related,untracked" \
    connection-state=established,related,untracked
add action=drop chain=input comment="drop invalid" connection-state=invalid
add action=drop chain=input comment="drop all from WAN" in-interface-list=WAN
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" \
    connection-state=established,related
add action=accept chain=forward comment=\
    "accept established,related, untracked" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="drop invalid" connection-state=invalid
add action=drop chain=forward comment="drop all from WAN not DSTNATed" \
    connection-nat-state=!dstnat connection-state=new in-interface-list=WAN
/ip firewall mangle
add action=change-mss chain=forward comment="change MSS" new-mss=1440 \
    passthrough=yes protocol=tcp tcp-flags=syn
add action=mark-connection chain=input comment=Sticky_PCC_CT_1 in-interface=\
    pppoe-out1-ct new-connection-mark=PCC_CT_1 passthrough=yes
add action=mark-routing chain=output connection-mark=PCC_CT_1 \
    new-routing-mark=PCC_ROUTE_CT_1 passthrough=yes
add action=mark-connection chain=input comment=Sticky_PCC_CT_2 in-interface=\
    pppoe-out2-ct new-connection-mark=PCC_CT_2 passthrough=yes
add action=mark-routing chain=output connection-mark=PCC_CT_2 \
    new-routing-mark=PCC_ROUTE_CT_2 passthrough=yes
add action=mark-connection chain=input comment=Sticky_PCC_CU_1 in-interface=\
    pppoe-out3-cu new-connection-mark=PCC_CU_1 passthrough=yes
add action=mark-routing chain=output connection-mark=PCC_CU_1 \
    new-routing-mark=PCC_ROUTE_CU_1 passthrough=yes
add action=mark-connection chain=input comment=Sticky_PCC_CU_2 in-interface=\
    pppoe-out4-cu new-connection-mark=PCC_CU_2 passthrough=yes
add action=mark-routing chain=output connection-mark=PCC_CU_2 \
    new-routing-mark=PCC_ROUTE_CU_2 passthrough=yes
add action=mark-connection chain=prerouting comment=PCC_CT_1 \
    dst-address-list=dpbr-CT dst-address-type=!local in-interface=bridge1 \
    new-connection-mark=PCC_CT_1 passthrough=yes per-connection-classifier=\
    both-addresses-and-ports:2/0
add action=mark-routing chain=prerouting connection-mark=PCC_CT_1 \
    dst-address-list=dpbr-CT in-interface=bridge1 new-routing-mark=\
    PCC_ROUTE_CT_1 passthrough=no
add action=mark-connection chain=prerouting comment=PCC_CT_2 \
    dst-address-list=dpbr-CT dst-address-type=!local in-interface=bridge1 \
    new-connection-mark=PCC_CT_2 passthrough=yes per-connection-classifier=\
    both-addresses-and-ports:2/1
add action=mark-routing chain=prerouting connection-mark=PCC_CT_2 \
    dst-address-list=dpbr-CT in-interface=bridge1 new-routing-mark=\
    PCC_ROUTE_CT_2 passthrough=no
add action=mark-connection chain=prerouting comment=PCC_CU_1 \
    dst-address-type=!local in-interface=bridge1 new-connection-mark=PCC_CU_1 \
    passthrough=yes per-connection-classifier=both-addresses-and-ports:2/0
add action=mark-routing chain=prerouting connection-mark=PCC_CU_1 \
    in-interface=bridge1 new-routing-mark=PCC_ROUTE_CU_1 passthrough=yes
add action=mark-connection chain=prerouting comment=PCC_CU_2 \
    dst-address-type=!local in-interface=bridge1 new-connection-mark=PCC_CU_2 \
    passthrough=yes per-connection-classifier=both-addresses-and-ports:2/1
add action=mark-routing chain=prerouting connection-mark=PCC_CU_2 \
    in-interface=bridge1 new-routing-mark=PCC_ROUTE_CU_2 passthrough=yes
/ip firewall nat
add action=dst-nat chain=dstnat dst-port=18999 in-interface-list=WAN \
    protocol=tcp to-addresses=10.10.7.53 to-ports=18999
add action=masquerade chain=srcnat out-interface=pppoe-out1-ct
add action=masquerade chain=srcnat out-interface=pppoe-out2-ct
add action=masquerade chain=srcnat out-interface=pppoe-out3-cu
add action=masquerade chain=srcnat out-interface=pppoe-out4-cu
/ip route
add check-gateway=ping distance=1 gateway=pppoe-out1-ct routing-mark=\
    PCC_ROUTE_CT_1
add check-gateway=ping distance=1 gateway=pppoe-out2-ct routing-mark=\
    PCC_ROUTE_CT_2
add check-gateway=ping distance=1 gateway=pppoe-out3-cu routing-mark=\
    PCC_ROUTE_CU_1
add check-gateway=ping distance=1 gateway=pppoe-out4-cu routing-mark=\
    PCC_ROUTE_CU_2
add distance=1 gateway=pppoe-out1-ct
add distance=2 gateway=pppoe-out2-ct
add distance=3 gateway=pppoe-out3-cu
add check-gateway=ping distance=4 gateway=pppoe-out4-cu
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set ssh disabled=yes
set api disabled=yes
set api-ssl disabled=yes
/system clock
set time-zone-name=Asia/Shanghai
/system ntp client
set enabled=yes primary-ntp=203.107.6.88 secondary-ntp=120.25.115.20 \
    server-dns-names=223.5.5.5,223.6.6.6
/system scheduler
add interval=1d name=pppoe-re-dailup on-event="/interface disable pppoe-out1-c\
    t\r\
    \n/interface disable pppoe-out2-ct\r\
    \n/interface enable pppoe-out1-ct\r\
    \n/interface enable pppoe-out2-ct\r\
    \n\r\
    \n/interface disable pppoe-out3-cu\r\
    \n/interface disable pppoe-out4-cu\r\
    \n/interface enable pppoe-out3-cu\r\
    \n/interface enable pppoe-out4-cu" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=oct/19/2020 start-time=04:00:00
