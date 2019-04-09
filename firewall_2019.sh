#!/bin/bash

# Inicio do Firewall

ip_lan="192.168.0.50"
ip_masc_lan="192.168.0.0/24"
lan=enp2s0

# redireciona para o standalone ou pc 
ip_redirect="192.168.0.60"
port_redirect=8888

ip_wan="192.168.0.50"
ip_masc_wan="192.168.0.0/24"
wan=enp2s0


#Rede eth0 = 192.168.2.0/24
#Internet eth1 = 192.168.254.0/24
echo "Inciando Firewall"

echo "Limpado Nat"
##Limpado Nat
sudo iptables -t nat -F
sudo iptables -t nat -X
sudo iptables -t nat -Z
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -F
sudo iptables -X
sudo iptables -Z
sudo iptables -F INPUT
sudo iptables -F OUTPUT
sudo iptables -F FORWARD
#sudo iptables -P INPUT ACCEPT
#sudo iptables -P FORWARD ACCEPT
#sudo iptables -P OUTPUT ACCEPT



echo "Definindo a Polica Padrao"
## Define a politica padrao
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT DROP
sudo iptables -t filter -P INPUT DROP
sudo iptables -t filter -P FORWARD DROP
sudo iptables -t filter -P OUTPUT ACCEPT
sudo iptables -t nat -P PREROUTING ACCEPT
sudo iptables -t nat -P POSTROUTING ACCEPT
sudo iptables -t nat -P OUTPUT ACCEPT
sudo iptables -t mangle -P PREROUTING ACCEPT
sudo iptables -t mangle -P OUTPUT ACCEPT


echo "Modulos"
##Modulos
sudo modprobe ip_tables
sudo modprobe ip_conntrack
sudo modprobe iptable_filter
sudo modprobe iptable_mangle
sudo modprobe iptable_nat
sudo modprobe ipt_LOG
sudo modprobe ipt_limit
sudo modprobe ipt_state
sudo modprobe ipt_REDIRECT
sudo modprobe ipt_owner
sudo modprobe ipt_REJECT
sudo modprobe ipt_MASQUERADE
sudo modprobe ip_conntrack_ftp
sudo modprobe ip_nat_ftp

echo "Mascaramento de rede para acesso externo"
##Mascaramento de rede para acesso externo
sudo iptables -t nat -A POSTROUTING -o $wan -j MASQUERADE
sudo iptables -A POSTROUTING -t nat -j MASQUERADE

echo "Ativando o Roteamento Dinamico"
##ativa o roteamento dinamico
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv4/ip_dynaddr

echo "Habilitando Localhost"
##Habilitando LocalHost:
sudo iptables -A INPUT -p tcp --syn -s 127.0.0.1 -j ACCEPT

echo "Redirecionando Porta 80 para 8082"
##Redirencionar portas 80 para 8082
sudo iptables -t nat -A PREROUTING -i $ip_lan -p tcp --dport 80 -j REDIRECT --to-port 8082

echo "Redirecionando CAMERA para IP SERVIDOR"
##Redirencionar portas CAMERA para IP SERVIDOR
sudo iptables -t nat -A PREROUTING -i $lan -p tcp --dport 42474 -m conntrack --ctstate NEW -j DNAT --to $ip_redirect:42474
sudo iptables -t nat -A PREROUTING -i $lan -p tcp --dport 9966 -m conntrack --ctstate NEW -j DNAT --to $ip_redirect:9966
sudo iptables -t nat -A PREROUTING -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Estabelecendo as Conexoes
echo "Estabelecendo Conexoes"
# -----------------------------------------------------------------------------------------------------------
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT 
sudo iptables -A OUTPUT -m state --state ESTABLISHED,RELATED,NEW -j ACCEPT 
sudo iptables -A FORWARD -m state --state ESTABLISHED,RELATED,NEW -j ACCEPT 

echo "Libera a Conexao para rede Interna"
## Libera a conexao para a rede interna
sudo iptables -t nat -A POSTROUTING -s $ip_masc_lan -j MASQUERADE

echo "Separa ICMP, TCP E UDP"
##Create separate chains for ICMP, TCP and UDP to traverse
sudo iptables -N allowed
sudo iptables -N tcp_packets
sudo iptables -N udp_packets
sudo iptables -N icmp_packets

echo "netbios"
## NETBIOS
# sudo iptables -A INPUT -p tcp -s $ip_masc_lan --dport 137:139 -j ACCEPT
# sudo iptables -A INPUT -p udp -s $ip_masc_lan --dport 137:139 -j ACCEPT

echo "dns Liberado"
## DNS - Libera a resolucao de nomes
sudo iptables -A INPUT -p tcp -s $ip_masc_lan --dport 53 -j ACCEPT
sudo iptables -A INPUT -p udp -s $ip_masc_lan --dport 53 -j ACCEPT

echo "Bloqueio U89 - Software burlador de proxy"
## Bloqueando U89 - software burlador de proxy
sudo iptables -A FORWARD -p tcp --dport 9666 -j DROP
sudo iptables -A FORWARD -p tcp --dport 443 -j DROP

#echo "Travando o msn e Liberando o acesso por Maquina"
## Libera as maquinas na rede que pode ter msn

#sudo iptables -A FORWARD -s $ip_masc_lan -p tcp --dport 1863 -j ACCEPT
#sudo iptables -A FORWARD -s $ip_masc_lan -d 65.54.179.192 -j ACCEPT
#sudo iptables -A FORWARD -p tcp --dport 1863 -j DROP
#sudo iptables -A FORWARD -d 65.54.179.192 -j DROP

echo "Terminal Server"
## Terminal Server
#sudo iptables -t nat -A PREROUTING -p tcp -i $wan --dport 3389 -j DNAT --to 192.168.2.253
#sudo iptables -t nat -A POSTROUTING -d 192.168.2.253 -j SNAT --to 192.168.2.254
sudo iptables -t nat -A PREROUTING -p tcp -i $wan --dport 3389 -j DNAT --to $ip_lan# ip do servidor
sudo iptables -t nat -A POSTROUTING -d $ip_lan -j SNAT --to 192.168.0.1

echo "Liberando SSH"
## Liberando SSH (porta 6689 e 22 )
sudo iptables -A INPUT -p tcp --dport 22 -i $ip_lan -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 6689 -i $ip_lan -j ACCEPT
sudo iptables -A INPUT -s $ip_masc_lan -p tcp --dport ssh -j ACCEPT

echo "Liberando SSH Externo"
## Liberando SSH Externo
sudo iptables -A INPUT -p tcp --dport 22 -i $wan -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 6689 -i $wan -j ACCEPT

#echo "Liberando SSH em Servidor Web"
## Liberando SSH em Servidor web
#sudo iptables -A INPUT -p tcp --dport 80 -i $wan -j ACCEPT

echo "Liberando Webmin"
## Liberando Webmin (porta 332)
sudo iptables -A INPUT -s $ip_masc_lan -p tcp --dport 332 -j ACCEPT
sudo iptables -A INPUT -s $ip_masc_lan -p tcp --dport 10000 -j ACCEPT
sudo iptables -A Input -s $ip_masc_lan -p tcp --dport 11000 -j ACCEPT

echo "Liberando Acesso ao Webmin Externo"
## Liberando acesso Webmin externo
sudo iptables -A INPUT -i $wan -p tcp --dport 332 -j ACCEPT

echo "Liberando Pacotes de Retorno da internet"
## ACCEPT (libera) pacotes de retorno da internet
sudo iptables -A INPUT -i ! $wan -j ACCEPT
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A OUTPUT -m state --state ESTABLISHED,RELATED,NEW -j ACCEPT
sudo iptables -A FORWARD -m state --state ESTABLISHED,RELATED,NEW -j ACCEPT

# HORA SERVIDOR
echo "Atualizando Hora"
# -----------------------------------------------------------------------------------------------------------
####### Serviços de Atualização de Horário com Servidor br.pool.ntp.org (Rede Interna ---> Internet) 
####### ------------------------------------------------------------------------------------------------ 
iptables -A OUTPUT -d br.pool.ntp.org -m state --state NEW -j ACCEPT 

#echo "Fechando as Portas do Samba para internet"
## Fechando as portas do samba caso fique de cara para a internet.
#sudo iptables -A INPUT -p tcp -i $wan --syn --dport 139 -j DROP
#sudo iptables -A INPUT -p tcp -i $wan --syn --dport 138 -j DROP

# SAMBA
echo "Liberando SAMBA Rede Interna"
# -----------------------------------------------------------------------------------------------------------
####### Serviços de Compatilhamento de Arquivos Somente para a Rede Interna
####### ------------------------------------------------------------------------------------------------ 
iptables -A INPUT -p tcp --dport 135:139 -m state --state NEW -j ACCEPT 
iptables -A INPUT -p udp --dport 135:139 -m state --state NEW -j ACCEPT 

iptables -A FORWARD -p tcp --dport 135:139 -m state --state NEW -j ACCEPT
iptables -A FORWARD -p udp --dport 135:139 -m state --state NEW -j ACCEPT

iptables -A OUTPUT -p tcp --dport 135:139 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p udp --dport 135:139 -m state --state NEW -j ACCEPT

#echo "Conexao via rede interna com destino ao Web Server"
## Aceita conexoes vindas da rede interna com destino ao web server
#sudo iptables -A INPUT -p tcp -i $ip_masc_lan --syn --dport 80 -j ACCEPT

#echo "Abre a faixa de endereco da rede local"
## Abre para uma faixa de endereco da rede local
#sudo iptables -A INPUT -p tcp --syn -s 192.168.2.0/255.255.255.0 -j ACCEPT

echo "Abrindo Porta de Conexao a Internet"
## Abre uma porta (inclusive para a Internet)
sudo iptables -A INPUT -p tcp --destination-port 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --destination-port 21 -j ACCEPT
sudo iptables -A INPUT -p tcp --destination-port 2121 -j ACCEPT
sudo iptables -A INPUT -p tcp --destination-port 8081 -j ACCEPT
sudo iptables -A INPUT -p tcp --destination-port 8082 -j ACCEPT
sudo iptables -A INPUT -p tcp --destination-port 8083 -j ACCEPT
sudo iptables -A INPUT -p tcp --destination-port 443 -j ACCEPT
sudo iptables -A INPUT -p tcp --destination-port 465 -j ACCEPT
sudo iptables -A INPUT -p tcp --destination-port 995 -j ACCEPT
sudo iptables -A INPUT -p tcp --destination-port 332 -j ACCEPT
sudo iptables -A INPUT -p tcp --destination-port 1863 -j ACCEPT
sudo iptables -A INPUT -p tcp --destination-port 4199 -j ACCEPT
sudo iptables -A INPUT -p tcp --destination-port 5959 -j ACCEPT
sudo iptables -A INPUT -p tcp --destination-port 3389 -j ACCEPT
sudo iptables -A INPUT -p tcp --destination-port 5900 -j ACCEPT
sudo iptables -A INPUT -p tcp --destination-port 5800 -j ACCEPT
sudo iptables -A INPUT -p tcp --destination-port 9966 -j ACCEPT
sudo iptables -A INPUT -p tcp --destination-port 32400 -j ACCEPT

##Trafego
sudo iptables -A INPUT -p tcp --destination-port 80 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 8081 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 8082 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 8083 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 21 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 2121 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 443 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 563 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 70 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 210 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 280 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 488 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 591 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 777 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 631 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 873 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 901 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 42801 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 2098 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 4199 -j DROP
sudo iptables -A OUTPUT -p tcp --destination-port 4199 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 5959 -j DROP
sudo iptables -A OUTPUT -p tcp --destination-port 5959 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 3389 -j DROP
sudo iptables -A OUTPUT -p tcp --destination-port 3389 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 139 -j DROP
sudo iptables -A OUTPUT -p tcp --destination-port 139 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 1863 -j DROP
sudo iptables -A OUTPUT -p tcp --destination-port 1863 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 5900 -j DROP
sudo iptables -A OUTPUT -p tcp --destination-port 5900 -j DROP
sudo iptables -A INPUT -p tcp --destination-port 5800 -j DROP
sudo iptables -A OUTPUT -p tcp --destination-port 5800 -j DROP
sudo iptables -A OUTPUT -p tcp --destination-port 9966 -j DROP
sudo iptables -A OUTPUT -p tcp --destination-port 32400 -j DROP

echo "Ignora Pings"
## Ignora pings
echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_all

echo "Protege contra Synflood"
## Protege contra synflood
echo "1" > /proc/sys/net/ipv4/tcp_syncookies

echo "Nat ao contrario"
## Desabilita o suporte a source routed packets
# Esta recurso funciona como um NAT ao contrario, que em certas circunstancias pode permitir que alguem de fora envie pacotes para micros dentro da rede localecho "0" >/proc/sys/net/ipv4/conf/eth0/accept_source_route
echo "0" > /proc/sys/net/ipv4/conf/$lan/accept_source_route
echo "0" > /proc/sys/net/ipv4/conf/$wan/accept_source_route

echo "Protecao contra ICMP Broadcasting"
## Protecao contra ICMP Broadcasting
echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

echo "Protecao Contra IP spoofing"
##Proteção Contra IP Spoofing
#sudo iptables -A INPUT -s 10.0.0.0/8 -i $wan -j DROP
#sudo iptables -A INPUT -s 172.16.0.0/16 -i $wan -j DROP
#sudo iptables -A INPUT -s 192.168.0.0/24 -i $wan -j DROP

echo "Block Black Orifice"
# Block Back Orifice
sudo iptables -A INPUT -p tcp --dport 31337 -j DROP
sudo iptables -A INPUT -p udp --dport 31337 -j DROP

echo "Block NetBus"
# Block NetBus
sudo iptables -A INPUT -p tcp --dport 12345:12346 -j DROP
sudo iptables -A INPUT -p udp --dport 12345:12346 -j DROP

echo "FIREWALL: NEW sem syn"
# "FIREWALL: NEW sem syn: "
sudo iptables -A FORWARD -p tcp ! --syn -m state --state NEW -j DROP

echo "Dropa pacotes mal formados"
# Dropa pacotes mal formados
sudo iptables -A FORWARD -m unclean -j DROP

echo "Proteção contra trinoo"
# Proteção contra trinoo
sudo iptables -N TRINOO
sudo iptables -A TRINOO -m limit --limit 15/m -j LOG --log-level 6 --log-prefix "FIREWALL: trinoo: "
sudo iptables -A TRINOO -j DROP
sudo iptables -A INPUT -p TCP -i $wan --dport 27444 -j TRINOO
sudo iptables -A INPUT -p TCP -i $wan --dport 27665 -j TRINOO
sudo iptables -A INPUT -p TCP -i $wan --dport 31335 -j TRINOO
sudo iptables -A INPUT -p TCP -i $wan --dport 34555 -j TRINOO
sudo iptables -A INPUT -p TCP -i $wan --dport 35555 -j TRINOO

echo "Proteção contra tronjans"
# Proteção contra tronjans
sudo iptables -N TROJAN
sudo iptables -A TROJAN -m limit --limit 15/m -j LOG --log-level 6 --log-prefix "FIREWALL: trojan: "
sudo iptables -A TROJAN -j DROP
sudo iptables -A INPUT -p TCP -i $wan --dport 666 -j TROJAN
sudo iptables -A INPUT -p TCP -i $wan --dport 666 -j TROJAN
sudo iptables -A INPUT -p TCP -i $wan --dport 4000 -j TROJAN
sudo iptables -A INPUT -p TCP -i $wan -- dport 6000 -j TROJAN
sudo iptables -A INPUT -p TCP -i $wan --dport 6006 -j TROJAN
sudo iptables -A INPUT -p TCP -i $wan --dport 16660 -j TROJAN

echo "Proteção contra worms"
# Proteção contra worms
sudo iptables -A FORWARD -p tcp --dport 135 -i $lan -j REJECT

echo "Proteção contra syn-flood"
# Proteção contra syn-flood
sudo iptables -A FORWARD -p tcp --syn -m limit --limit 2/s -j ACCEPT

echo "Proteção contra port scanners"
# Proteção contra port scanners
sudo iptables -N SCANNER
sudo iptables -A SCANNER -m limit --limit 15/m -j LOG --log-level 6 --log-prefix "FIREWALL: port scanner: "
sudo iptables -A SCANNER -j DROP
sudo iptables -A INPUT -p tcp --tcp-flags ALL FIN,URG,PSH -i $wan -j SCANNER
sudo iptables -A INPUT -p tcp --tcp-flags ALL NONE -i $wan -j SCANNER
sudo iptables -A INPUT -p tcp --tcp-flags ALL ALL -i $wan -j SCANNER
sudo iptables -A INPUT -p tcp --tcp-flags ALL FIN,SYN -i $wan -j SCANNER
sudo iptables -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -i $wan -j SCANNER
sudo iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -i $wan -j SCANNER
sudo iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -i $wan -j SCANNER

echo "Bloqueio de NetBios"
#Bloqueio de NetBios
#sudo iptables -t nat -A PREROUTING -p tcp --dport 445 -j DROP
#sudo iptables -t nat -A PREROUTING -p tcp --dport 135 -j DROP
#sudo iptables -t nat -A PREROUTING -p tcp --dport 137 -j DROP
#sudo iptables -t nat -A PREROUTING -p tcp --dport 138 -j DROP
#sudo iptables -t nat -A PREROUTING -p tcp --dport 139 -j DROP
#sudo iptables -t nat -A PREROUTING -p udp --dport 445 -j DROP
#sudo iptables -t nat -A PREROUTING -p udp --dport 135 -j DROP
#sudo iptables -t nat -A PREROUTING -p udp --dport 137 -j DROP
#sudo iptables -t nat -A PREROUTING -p udp --dport 138 -j DROP
#sudo iptables -t nat -A PREROUTING -p udp --dport 139 -j DROP


echo "Loga tentativa de acesso a determinadas portas"
# Loga tentativa de acesso a determinadas portas
sudo iptables -A INPUT -p tcp --dport 21 -i $wan -j LOG --log-level 6 --log-prefix "FIREWALL: ftp: "
sudo iptables -A INPUT -p tcp --dport 2121 -i $wan -j LOG --log-level 6 --log-prefix "FIREWALL: ftp: "
sudo iptables -A INPUT -p tcp --dport 23 -i $wan -j LOG --log-level 6 --log-prefix "FIREWALL: telnet: "
sudo iptables -A INPUT -p tcp --dport 25 -i $wan -j LOG --log-level 6 --log-prefix "FIREWALL: smtp: "
sudo iptables -A INPUT -p tcp --dport 80 -i $wan -j LOG --log-level 6 --log-prefix "FIREWALL: http: "
sudo iptables -A INPUT -p tcp --dport 110 -i $wan -j LOG --log-level 6 --log-prefix "FIREWALL: pop3: "
sudo iptables -A INPUT -p udp --dport 111 -i $wan -j LOG --log-level 6 --log-prefix "FIREWALL: rpc: "
sudo iptables -A INPUT -p tcp --dport 113 -i $wan -j LOG --log-level 6 --log-prefix "FIREWALL: identd: "
sudo iptables -A INPUT -p tcp --dport 137:139 -i $wan -j LOG --log-level 6 --log-prefix "FIREWALL: samba: "
sudo iptables -A INPUT -p udp --dport 137:139 -i $wan -j LOG --log-level 6 --log-prefix "FIREWALL: samba: "
sudo iptables -A INPUT -p tcp --dport 161:162 -i $wan -j LOG --log-level 6 --log-prefix "FIREWALL: snmp: "
sudo iptables -A INPUT -p tcp --dport 6667:6668 -i $wan -j LOG --log-level 6 --log-prefix "FIREWALL: irc: "
sudo iptables -A INPUT -p tcp --dport 3128 -i $wan -j LOG --log-level 6 --log-prefix "FIREWALL: squid: "

echo "Protecao contra Ping od death, ataques DoS,"
## Protecao diversas contra portscanners, ping of death, ataques DoS, etc.
sudo iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT
sudo iptables -A FORWARD -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT
sudo iptables -A FORWARD -p tcp -m limit --limit 1/s -j ACCEPT
sudo iptables -A FORWARD -p tcp --syn -m limit --limit 1/s -j ACCEPT
sudo iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s -j ACCEPT
sudo iptables -A FORWARD -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s -j ACCEPT
sudo iptables -A FORWARD --protocol tcp --tcp-flags ALL SYN,ACK -j DROP
sudo iptables -A FORWARD -m unclean -j DROP
sudo iptables -A INPUT -m state --state INVALID -j DROP
sudo iptables -N VALID_CHECK
sudo iptables -A VALID_CHECK -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP
sudo iptables -A VALID_CHECK -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
sudo iptables -A VALID_CHECK -p tcp --tcp-flags ALL ALL -j DROP
sudo iptables -A VALID_CHECK -p tcp --tcp-flags ALL FIN -j DROP
sudo iptables -A VALID_CHECK -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
sudo iptables -A VALID_CHECK -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
sudo iptables -A VALID_CHECK -p tcp --tcp-flags ALL NONE -j DROP
sudo iptables -A INPUT -p udp -s 0/0 -i $lan --dport 33435:33525 -j REJECT
sudo iptables -A INPUT -m state --state INVALID -j REJECT
sudo iptables -A INPUT -s 0.0.0.0/0 -p icmp -j DROP

echo "Manter conexoes jah estabelecidas para nao parar"
## Manter conexoes jah estabelecidas para nao parar
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

echo "Interface Loopback"
## Abre para a interface de loopback.
# Esta regra e essencial para o KDE e outros programas graficos funcionarem adequadamente.
sudo iptables -A INPUT -p tcp --syn -s 127.0.0.1/255.0.0.0 -j ACCEPT
sudo iptables -A INPUT -i lo -j ACCEPT

echo "Fechando Todas Portas"
## Esta regra e coracao do firewall ,
# ela bloqueia qualquer conexoes que nao tenha sido permitida acima.
sudo iptables -A INPUT -p tcp --syn -j DROP

#----SAVE
iptables-save > iptables-save > /etc/webmin/firewall/iptables.save
#----RESTORE
iptables-restore < /etc/webmin/firewall/iptables.save
#---FLUSH
iptables -F
#---FINISH IPTABLES
