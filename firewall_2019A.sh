#LIMPA TABELA
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -X
iptables -F
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -I INPUT 1 -i lo -j ACCEPT
#SSH
iptables -A INPUT -p tcp --dport ssh -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
#FTP
iptables -A INPUT -p tcp --dport 21 -j ACCEPT
iptables -A INPUT -p tcp --dport 2121 -j ACCEPT
#DNS
iptables -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --dport 53 -j ACCEPT
#WEB
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
#WEB REDIRECT
iptables -t nat -A OUTPUT -o enp2s0 -p tcp --dport 80 -j REDIRECT --to-port 8082
#WEB OUTRAS PORTAS
iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
iptables -A INPUT -p tcp --dport 8081 -j ACCEPT
iptables -A INPUT -p tcp --dport 8082 -j ACCEPT
iptables -A INPUT -p tcp --dport 8083 -j ACCEPT
iptables -A INPUT -p tcp --dport 8084 -j ACCEPT
#SAMBA
iptables -A INPUT -p tcp --dport 137 -j ACCEPT
iptables -A INPUT -p tcp --dport 138 -j ACCEPT
iptables -A INPUT -p tcp --dport 139 -j ACCEPT
iptables -A INPUT -p tcp --dport 445 -j ACCEPT
#WEBMIN
iptables -A INPUT -p tcp --dport 10000 -j ACCEPT
#WEBMIN ALTERNATIVE
iptables -A INPUT -p tcp --dport 11000 -j ACCEPT
#PLEX
iptables -A INPUT -p tcp --dport 34200 -j ACCEPT
#NEGA TODOS
iptables -A INPUT -j DROP
#SERVER
iptables -I INPUT 1 -s 192.168.0.50 -j ACCEPT
iptables -A INPUT -s 192.168.0.50 -j ACCEPT
#CAMERAS REDIRECIONA DO SERVIDOR PARA O STANDALONE
sysctl net.ipv4.ip_forward=1
DEFAULT_FORWARD_POLICY="ACCEPT"
iptables -t nat -A PREROUTING -i enp2s0 -p tcp --dport 9966 -m conntrack --ctstate NEW -j DNAT --to 192.168.0.60:9966
iptables -t nat -A PREROUTING -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A POSTROUTING -t nat -j MASQUERADE
#LOG TODOS
iptables -N LOGGING
iptables -A INPUT -j LOGGING
iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables Packet Dropped: " --log-level 7
iptables -A LOGGING -j DROP
iptables -L

iptables-save > /etc/webmin/firewall/iptables.save
iptables-restore < /etc/webmin/firewall/iptables.save
