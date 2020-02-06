#!/bin/bash

iniciar(){
#Carrega o modulo
modprobe iptable_nat
#Ativa o compartilharmento da internet para o dhcp
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

#libera as portas webmin
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port webmin -j ACCEPT

#libera as portas smtp
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port smtp -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port smtp -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port smtps -j ACCEPT

#libera http, https, pop3, pop3s
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port http -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port https -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port pop3 -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port pop3s -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port poppassd -j ACCEPT

#libera imap
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port imap -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port imaps -j ACCEPT

#libera o ISP
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port 8080 -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port 8089 -j ACCEPT

#libera SSH
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port ssh -j ACCEPT

#libera DNS
iptables -A INPUT -p udp -s 0/0 -d 0/0 --destination-port domain -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port domain -j ACCEPT

#libera FTP
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port ftp-data -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port ftp -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port 32000:65534 -j ACCEPT
#libera mysql
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port mysql -j ACCEPT

#libera as portas do DVR
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port 3500 -j ACCEPT
iptables -A INPUT -p udp -s 0/0 -d 0/0 --destination-port 3500 -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port 8200 -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port 8200 -j ACCEPT
iptables -A OUTPUT -p tcp -s 0/0 -d 0/0 --destination-port 3500 -j ACCEPT
iptables -A OUTPUT -p tcp -s 0/0 -d 0/0 --destination-port 8200 -j ACCEPT
iptables -A OUTPUT -p udp -s 0/0 -d 0/0 --destination-port 3500 -j ACCEPT
iptables -A OUTPUT -p udp -s 0/0 -d 0/0 --destination-port 8200 -j ACCEPT
iptables -A OUTPUT -p udp -s 0/0 -d 0/0 --destination-port 34599 -j ACCEPT
iptables -A OUTPUT -p udp -s 0/0 -d 0/0 --destination-port 34567 -j ACCEPT
#libera remote desktop
iptables -A OUTPUT -p udp -s 0/0 -d 0/0 --destination-port 3389 -j ACCEPT

#libera a porta 465 para acesso externo para uso do smtp do zpainel
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --destination-port 587 -j ACCEPT
iptables -A INPUT -p udp -s 0/0 -d 0/0 --destination-port 587 -j ACCEPT

iptables -A OUTPUT -p tcp -s 0/0 -d 0/0 --destination-port 587 -j ACCEPT
iptables -A OUTPUT -p udp -s 0/0 -d 0/0 --destination-port 587 -j ACCEPT

#bloquea facebook pc estoque
iptables -A FORWARD -i eth1 -s 192.168.15.100 -m string --algo bm --string "facebook.com" -j DROP
iptables -A FORWARD -i eth1 -s 192.168.15.100 -m string --algo bm --string "twitter.com" -j DROP

#bloqueia gamevicio, ou outros sites
iptables -A FORWARD -i eth1 -s 192.168.15.100 -m string --algo bm --string "gamevicio.com" -j DROP
iptables -A FORWARD -i eth1 -s 192.168.15.100 -m string --algo bm --string "youtube.com" -j DROP

#redireciona ip externo para ip do dvr
#iptables -t nat -A PREROUTING -p tcp --dport 3500 -j DNAT --to-destination 192.168.0.109:3500
iptables -t nat -A PREROUTING -p tcp -i eth1 -d 179.111.244.97 --dport 34599 -j DNAT --to-destination 192.168.15.55:34599
iptables -t nat -A PREROUTING -p tcp -i eth1 -d 179.111.244.97 --dport 34599 -j DNAT --to-destination 192.168.15.55:34599
iptables -t nat -A PREROUTING -p tcp -i eth1 -d 179.111.244.97 --dport 34567 -j DNAT --to-destination 192.168.15.55:34567
iptables -t nat -A PREROUTING -p tcp -i eth1 -d 179.111.244.97 --dport 34567 -j DNAT --to-destination 192.168.15.55:34567

#redireciona ip externo paras servidor remote desktop facility
iptables -t nat -A PREROUTING -p tcp -i eth0 -d 179.111.244.97 --dport 3389 -j DNAT --to-destination 192.168.15.55:3389
iptables -t nat -A PREROUTING -p tcp -i eth0 -d 192.168.15.100 --dport 3389 -j DNAT --to-destination 192.168.15.55:3389


#redireciona acesso eth0 para 192.168.0.111 ,portas 80,8080, 443, 110, 25, 587 e 53
iptables -t nat -A PREROUTING -p tcp -i eth1 -d 179.111.244.97 --dport 80 -j DNAT --to-destination 192.168.0.100:80
iptables -t nat -A PREROUTING -p tcp -i eth1 -d 179.111.244.97 --dport 8080 -j DNAT --to-destination 192.168.0.100:8080

iptables -t nat -A PREROUTING -p tcp -i eth1 -d 179.111.244.97 --dport 443 -j DNAT --to-destination 192.168.15.100:443
iptables -t nat -A PREROUTING -p tcp -i eth1 -d 179.111.244.97 --dport 110 -j DNAT --to-destination 192.168.15.100:110
iptables -t nat -A PREROUTING -p tcp -i eth1 -d 179.111.244.97 --dport 25 -j DNAT --to-destination 192.168.15.100:25
iptables -t nat -A PREROUTING -p tcp -i eth1 -d 179.111.244.97 --dport 587 -j DNAT --to-destination 192.168.15.100:587


iptables -A FORWARD -i eth1 -o eth1 -p tcp -d 192.168.15.100 --dport 80 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth1 -p tcp -d 192.168.15.100 --dport 8080 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth1 -p tcp -d 192.168.15.100 --dport 8889 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth1 -p tcp -d 192.168.15.100 --dport 10000 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth1 -p tcp -d 192.168.15.100 --dport 443 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth1 -p tcp -d 192.168.15.100 --dport 110 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth1 -p tcp -d 192.168.15.100 --dport 25 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth1 -p tcp -d 192.168.15.100 --dport 587 -j ACCEPT

}


parar(){
iptables -F
iptables -F -t nat
}
case "$1" in
"start")iniciar;;
"stop")parar;;
"restart")parar; iniciar;;
*) echo "Escolha um parametro: Start, Stop ou Restart"
esac

