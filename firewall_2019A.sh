sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -F
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT]
sudo iptables -A INPUT -p tcp --dport ssh -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 137 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 138 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 139 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 445 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 8080 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 8081 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 8082 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 8083 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 8084 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 11000 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 34200 -j ACCEPT
sysctl net.ipv4.ip_forward=1
iptables -t nat -A PREROUTING -i enp2s0 -p tcp --dport 42474 -m conntrack --ctstate NEW -j DNAT --to 192.168.0.60:42474
iptables -t nat -A PREROUTING -i enp2s0 -p tcp --dport 9966 -m conntrack --ctstate NEW -j DNAT --to 192.168.0.60:9966
iptables -t nat -A PREROUTING -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A POSTROUTING -t nat -j MASQUERADE

sudo iptables -I INPUT 1 -i lo -j ACCEPT
sudo iptables -P INPUT DROP
sudo iptables -P INPUT ACCEPT
sudo iptables -A INPUT -j DROP

sudo iptables-save > /etc/webmin/firewall/iptables.save
sudo iptables-restore < /etc/webmin/firewall/iptables.save
