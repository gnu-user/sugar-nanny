#!/bin/bash

OUR_IP=$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')

for prog in {iptables,ip6tables};
do
    $prog -F
    $prog -P INPUT DROP
    $prog -A INPUT -i lo -p all -j ACCEPT
    $prog -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

    if [ $prog == iptables ];
    then
        # Ban all ecatel servers
        #$prog -I INPUT -m iprange --src-range 77.45.128.0-77.45.191.255 -j DROP
        $prog -A INPUT -p icmp --icmp-type 8 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
        $prog -A OUTPUT -p icmp --icmp-type 0 -m state --state ESTABLISHED,RELATED -j ACCEPT
    else
        $prog -A INPUT -p ipv6-icmp -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
        $prog -A OUTPUT -p ipv6-icmp -m state --state ESTABLISHED,RELATED -j ACCEPT
    fi

    # SSH ports
    $prog -A INPUT -p tcp -m tcp --dport 8888 -j ACCEPT
    # Website
    $prog -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
    $prog -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
    $prog -A INPUT -p tcp -m tcp --dport 8080 -j ACCEPT
    $prog -A INPUT -p tcp -m tcp --dport 9090 -j ACCEPT
    # Web Sockets
    $prog -A INPUT -p tcp -m tcp --dport 13000 -j ACCEPT
    $prog -A INPUT -p tcp -m tcp --dport 13001 -j ACCEPT
    $prog -A INPUT -p tcp -m tcp --dport 13002 -j ACCEPT
    # DNS
    $prog -A INPUT -p udp -m udp --dport 53 -j ACCEPT
    $prog -A INPUT -p tcp -m tcp --dport 53 -j ACCEPT

: <<EOF
    # Taken from http://feeds.dshield.org/block.txt
    # Add some general attacking IPs
    $prog -A INPUT -s   218.77.79.0/24 -j DROP
    $prog -A INPUT -s   93.174.93.0/24 -j DROP
    $prog -A INPUT -s   198.20.69.0/24 -j DROP
    $prog -A INPUT -s 124.232.142.0/24 -j DROP
    $prog -A INPUT -s  184.82.124.0/24 -j DROP
    $prog -A INPUT -s    93.180.5.0/24 -j DROP
    $prog -A INPUT -s    71.6.165.0/24 -j DROP
    $prog -A INPUT -s 134.147.203.0/24 -j DROP
    $prog -A INPUT -s   198.20.70.0/24 -j DROP
    $prog -A INPUT -s    77.36.59.0/24 -j DROP
    $prog -A INPUT -s  66.240.236.0/24 -j DROP
    $prog -A INPUT -s 107.182.135.0/24 -j DROP
    $prog -A INPUT -s  66.240.192.0/24 -j DROP
    $prog -A INPUT -s    71.6.167.0/24 -j DROP
    $prog -A INPUT -s  60.172.246.0/24 -j DROP
    $prog -A INPUT -s   23.88.235.0/24 -j DROP
    $prog -A INPUT -s  87.238.145.0/24 -j DROP
    $prog -A INPUT -s  66.192.113.0/24 -j DROP
    $prog -A INPUT -s  82.221.105.0/24 -j DROP
    $prog -A INPUT -s  195.69.223.0/24 -j DROP

    # Taken from https://github.com/MPOS/php-mpos/wiki/Basic-DoS-Protection

    # Rule 1: Limit new connections, after 200 packets, to 50 per minute
    # $prog -A INPUT -p tcp --dport 80 -m state --state NEW -m limit --limit 50/minute --limit-burst 200 -j ACCEPT

    # Rule 2: Limit existing connections to 50 packets per second
    # $prog -A INPUT -m state --state RELATED,ESTABLISHED -m limit --limit 50/second --limit-burst 50 -j ACCEPT

    # Rule 3: Drop general script kiddies
    $prog -A INPUT -i eth0 -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
    $prog -A INPUT -i eth0 -p tcp -m tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
    $prog -A INPUT -i eth0 -p tcp -m tcp --tcp-flags SYN,RST SYN,RST -j DROP
    $prog -A INPUT -i eth0 -p tcp -m tcp --tcp-flags FIN,RST FIN,RST -j DROP
    $prog -A INPUT -i eth0 -p tcp -m tcp --tcp-flags FIN,ACK FIN -j DROP
    $prog -A INPUT -i eth0 -p tcp -m tcp --tcp-flags ACK,URG URG -j DROP

    # Rule 4: Drop port scans
    $prog -N PORT_SCANNING
    $prog -A PORT_SCANNING -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s -j RETURN
    $prog -A PORT_SCANNING -j DROP

    # Rule 5: Protect against spoofed IPs
    $prog -A INPUT -s $OUR_IP/32 -j DROP

    # Rule 6: Protect against XMAS packets
    $prog -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP

    # Rule 7: Protect against Smurf Attacks
    # Limit ICMP requests to 1 every second, or drop them all
    $prog -A INPUT -p icmp -m limit --limit 1/second --limit-burst 1 -j ACCEPT
    # Comment above and uncomment below to just drop ICMP
    # $prog -A INPUT -p icmp -j DROP

    # Rule 8: Advanced SYN filter
    # Severely limit new connections, don't think we can do this
    # Delete rule from above
    # $prog -D INPUT -p tcp --dport 80 -m state --state NEW -m limit --limit 50/minute --limit-burst 200 -j ACCEPT
    # $prog -A INPUT -p tcp -m state --state NEW -m limit --limit 2/second --limit-burst 2 -j ACCEPT

    # Rule 9: Only keep DNS udp
    $prog -A INPUT -p udp --sport 53 -j ACCEPT
    $prog -A INPUT -p udp --dport 53 -j ACCEPT
    $prog -A OUTPUT -p udp --sport 53 -j ACCEPT
    $prog -A OUTPUT -p udp --dport 53 -j ACCEPT
    $prog -A INPUT -p udp -j DROP
    $prog -A OUTPUT -p udp -j DROP
EOF

    $prog -A INPUT -j DROP

done

# Save the rules so they're persistent
service iptables-persistent save
