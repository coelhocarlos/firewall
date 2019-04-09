echo  IPTABLES RULES
#------------------------
#-----Allow Established and Related Incoming Connections
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -i enp2s0 -j ACCEPT
iptables -A OUTPUT -o enp2s0 -j ACCEPT
#---- RULES CAM
iptables -F
iptables -t nat -F
iptables -X

iptables -t nat -A PREROUTING -p tcp 192.168.0.50 --dport 34599 -j DNAT --to-destination 192.168.0.55:34599
iptables -t nat -A POSTROUTING -p tcp -d 192.168.0.50 --dport 34599 -j SNAT --to-source 192.168.0.55

#-----Allow Established Outgoing Connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
#-----Internal to External
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT 
#-----Drop Invalid Packets
#iptables -A FORWARD -i eth1 -o enp2s0 -j ACCEPT


#----Allow All Incoming SSH 
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -s 15.15.15.0/24 --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT
#----Allow Outgoing SSH
iptables -A OUTPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT
#----Allow All Incoming HTTP
iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT
#----Allow All Incoming HTTPS
iptables -A INPUT -p tcp --dport 443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 443 -m conntrack --ctstate ESTABLISHED -j ACCEPT
#----Allow All Incoming HTTP and HTTPS
iptables -A INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate ESTABLISHED -j ACCEPT
#----Allow All Incoming FTP
iptables -A INPUT -p tcp --dport 21-m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 21-m conntrack --ctstate ESTABLISHED -j ACCEPT
#----Allow MySQL from Specific IP Address or Subnet
iptables -A INPUT -p tcp -s 192.168.0.0/24 --dport 3306 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 3306 -m conntrack --ctstate ESTABLISHED -j ACCEPT
#----Allow Email  
iptables -A INPUT -p tcp --dport 25 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 25 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 143 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 143 -m conntrack --ctstate ESTABLISHED -j ACCEPT
#---Allow Eamail SMTP 
iptables -A INPUT -p tcp --dport 143 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 143 -m conntrack --ctstate ESTABLISHED -j ACCEPT
#---Allow Eamail IMAP
iptables -A INPUT -p tcp --dport 993 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 993 -m conntrack --ctstate ESTABLISHED -j ACCEPT
#---Allow All Incoming POP3
iptables -A INPUT -p tcp --dport 110 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 110 -m conntrack --ctstate ESTABLISHED -j ACCEPT
#---Allow All Incoming POP3S
iptables -A INPUT -p tcp --dport 995 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 995 -m conntrack --ctstate ESTABLISHED -j ACCEPT
#---Allow All TEAMSPEAK3
iptables -A INPUT -p tcp --dport 10011 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10011 -m conntrack --ctstate ESTABLISHED -j ACCEPT

iptables -A INPUT -p tcp -m tcp --dport 10000 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 11100 -j ACCEPT

iptables -A INPUT -p tcp --dport 30033 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 30033 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp --dport  9987 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p udp --sport  9987 -m conntrack --ctstate ESTABLISHED -j ACCEPT
#---Allow All MINECRAFT
iptables -A INPUT -p tcp --dport 25565 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 25565 -m conntrack --ctstate ESTABLISHED -j ACCEPT
#--Allow All PXE
iptables -A INPUT -p ALL -i $INET_IFACE -s 192.168.0.0/24 -j ACCEPT
iptables -A INPUT -p ALL -i $INET_IFACE -d 192.168.0.255 -j ACCEPT
iptables -A udp_inbound -p UDP -s 0/0 --destination-port 69 -j ACCEPT
#--Allow All QUAKE
iptables -A INPUT -p udp -m udp --dport 27910:27912 -j ACCEPT
#--Allow All CSTRIKE
iptables -A INPUT -p udp -m udp --dport 27915:27917 -j ACCEPT
#---IP POR REDIRECT ALLOW MYTH - CAM
iptables -t nat -A PREROUTING -i enp2s0 -p tcp --dport 42474 -m conntrack --ctstate NEW -j DNAT --to 192.168.0.60:42474
iptables -t nat -A PREROUTING -i enp2s0 -p tcp --dport 9966 -m conntrack --ctstate NEW -j DNAT --to 192.168.0.60:9966
iptables -t nat -A PREROUTING -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
#----SAVE
iptables-save > iptables-save > /etc/webmin/firewall/iptables.save
#----RESTORE
iptables-restore < /etc/webmin/firewall/iptables.save
#---FLUSH
iptables -F
#---FINISH IPTABLES
