#! /bin/bash 
#Configuracao Firewall atraves do iptables
#Autoria do Script
#"::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
#"| Script de Firewall - IPTABLES"
#"| Criado por: "
#"| membros da comunidade viva o linux"
#"| Tecnico em Informatica"
#"| ""
#"| Uso: firewall start|stop|restart"
#"::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"

###########################
#######TITULO ABRE####### #
echo "Iniciando FIREWALL"
###########################

##################################################################
#Os diversos modulos do iptables sao chamados atraves do modprobe#
##################################################################

modprobe ip_tables
modprobe iptable_nat
modprobe ip_conntrack
modprobe ip_conntrack_ftp
modprobe ip_nat_ftp
modprobe ipt_LOG
modprobe ipt_REJECT
modprobe ipt_MASQUERADE
modprobe ipt_state
modprobe ipt_multiport
modprobe iptable_mangle
modprobe ipt_tos
modprobe ipt_limit
modprobe ipt_mark
modprobe ipt_MARK

echo "subindo os modulos do IPTABLE e NETFILTRE"
echo "ON .......................................................[#OK]"

####################
#Interfaces de Rede#
####################
LAN=enp2s0

echo "ativado o placa de rede enp2s0"
echo "ON ........................................................[#OK]"

###########################
#Mensagem de inicializacao#
###########################

echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo "| Script de Firewall - IPTABLES"
echo "| Criado por: Josue Santos"
echo "| membro da comunidade viva o linux"
echo "| Tecnico em Informatica"
echo "| josueandres.fcb@gmail.com"
echo "| Uso: firewall start|stop|restart"
echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo 
echo "=========================================================|"
echo "|:INICIANDO A CONFIGURACAO DO FIREWALL NETFILTER ATRAVES:|"
echo "|:                    DO IPTABLES                       :|"
echo "=========================================================|"

######################
#Zera todas as Regras#
######################

echo "Zerando todas as Regras"
iptables -F
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X

########################################
##Bloqueia tudo, nada entra e nada sai##
########################################

echo "Fechando tudo..."
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

###################################
###Libera conexoes estabelecidas###
###################################

iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -m state --state RELATED,ESTABLISHED,NEW -j ACCEPT
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED,NEW -j ACCEPT

iptables -A INPUT -i lo -j ACCEPT

echo "Liberando conexoes..."
echo "ON.......................................................[#ON]"

###################
#COMPARTILHAMENTO##
###################

iptables -t nat -A POSTROUTING -o $LAN -j MASQUERADE

echo "Libera Compartilhamento"
echo "ON.......................................................[#ON]"

############################################
#Bloqueio de scanners ocultos (Shealt Scan)#
############################################

iptables -A FORWARD -p tcp --tcp-flags SYN,ACK, FIN,  -m limit --limit 1/s -j ACCEPT
echo "bloqueado scanners ocultos"
echo "ON ......................................................[#OK]"

#########################
#Bloqueio Anti-Spoofings#
#########################

iptables -A INPUT -s 127.0.0.0/8 -i $LAN -j DROP
iptables -A INPUT -s 127.0.0.0/8 -i $LAN  -j DROP
iptables -A INPUT -s 192.168.0.0/24 -i $LAN  -j DROP
iptables -A INPUT -s 192.168.0.0/24 -i $LAN  -j DROP

echo "ativado o bloqueio de tentativa de ataque do tipo Anti-spoofings"
echo "ON .....................................................[#OK]"

#######################################
#Bloqueio de ataque ssh de forca bruta#
#######################################

iptables -N SSH-BRUT-FORCE
iptables -A INPUT -i $LAN -p tcp --dport 22 -j SSH-BRUT-FORCE
iptables -A SSH-BRUT-FORCE -m limit --limit 1/s --limit-burst 4 -j RETURN
iptables -A SSH-BRUT-FORCE -j DROP

echo "ativado o bloqueio a tentativa de ataque do tipo SSH-BRUT-FORCE"
echo "ON .....................................................[#OK]"

###################################
#Bloquear ataque do tipo SYN-FLOOD#
###################################

echo "0" > /proc/sys/net/ipv4/tcp_syncookies
iptables -N syn-flood
iptables -A INPUT -i $LAN -p tcp --syn -j syn-flood
iptables -A syn-flood -m limit --limit 1/s --limit-burst 4 -j RETURN
iptables -A syn-flood -j DROP

echo "ativado o bloqueio de ataque do tipo SYN-FLOOD"
echo "ON .....................................................[#OK]"

################################################# 
#Descarte de pacotes nao-identificado ICMP (ping)
#################################################

iptables -A OUTPUT -m state -p icmp --state INVALID -j DROP

echo "ativado o bloqueio a tentativa de ataque do tipo PING-ICMP"
echo "ON .....................................................[#OK]"

######################
#Contra Pings da morte
######################

echo "0" > /proc/sys/net/ipv4/icmp_echo_ignore_all
iptables -N PING-MORTE
iptables -A INPUT -p icmp --icmp-type echo-request -j PING-MORTE
iptables -A PING-MORTE -m limit --limit 1/s --limit-burst 4 -j RETURN
iptables -A PING-MORTE -j DROP

echo "ativado o bloqueio a ataque do tipo ping da morte"
echo "ON .....................................................[#OK]"

############################################################################
##Impede ataques DoS a maquina limitando a quantidade de respostas do ping##
############################################################################

iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j DROP

echo "Previne ataques DoS"
echo "ON .....................................................[#OK]"

#################################
##Bloqueia completamente o ping##
#################################

iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

echo "Previne ataques PING"
echo "ON .....................................................[#OK]"

##########################
##Politicas de seguranca##
##########################

echo 0 > /proc/sys/net/ipv4/conf/all/accept_source_route
echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects 
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
echo 1 > /proc/sys/net/ipv4/tcp_syncookies
echo 1 > /proc/sys/net/ipv4/conf/default/rp_filter
iptables -A INPUT -m state --state INVALID -j DROP

echo "Implementacao de politicas de seguranca"
echo "ON .....................................................[#OK]"

#######################################################################################
##Libera o acesso via SSH e Limita o numero de tentativas de acesso a 4 a cada minuto##
#######################################################################################

iptables -I INPUT -p tcp --dport 22 -i eth0 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p udp --dport 22 -j ACCEPT

# [ SSH Interno ]
iptables -t nat -A PREROUTING -p tcp --dport 22 -s 192.168.0.50/24 -j ACCEPT
iptables -t nat -A PREROUTING -p udp --dport 22 -s 192.168.0.50/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -s 192.168.0.50/24 -j ACCEPT
iptables -A INPUT -p udp --dport 22 -s 192.168.0.50/24 -j ACCEPT

# [ SSH Externo ]
iptables -t nat -A PREROUTING -p tcp --dport 22 -j ACCEPT
iptables -t nat -A PREROUTING -p udp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p udp --dport 22 -j ACCEPT

echo "Liberando SSH"
echo "On......................................................[#OK]"
#####################
##Libera as Cameras##
#####################
iptables -t nat -A PREROUTING -i enp2s0 -p tcp --dport 42474 -m conntrack --ctstate NEW -j DNAT --to 192.168.0.60:42474
iptables -t nat -A PREROUTING -i enp2s0 -p tcp --dport 9966 -m conntrack --ctstate NEW -j DNAT --to 192.168.0.60:9966
iptables -t nat -A PREROUTING -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A POSTROUTING -t nat -j MASQUERADE
echo "Liberando Cameras em rede Roteadas"
echo "On......................................................[#OK]"

#################
##Libera Webmin##
#################
iptables -t nat -A PREROUTING -p tcp --dport 10000 -j ACCEPT
iptables -t nat -A PREROUTING -p udp --dport 10000 -j ACCEPT
iptables -A INPUT -p tcp --dport 10000 -j ACCEPT
iptables -A INPUT -p udp --dport 10000 -j ACCEPT

echo "Liberando Webmin porta padrão 10000"
echo "On......................................................[#OK]"
#alternative Port Webmin
iptables -t nat -A PREROUTING -p tcp --dport 10000 -j ACCEPT
iptables -t nat -A PREROUTING -p udp --dport 10000 -j ACCEPT
iptables -A INPUT -p tcp --dport 10000 -j ACCEPT
iptables -A INPUT -p udp --dport 10000 -j ACCEPT

echo "Liberando Webmin porta alternativa 11000"
echo "On......................................................[#OK]"

##################
##Libera o Samba##
##################

iptables -A INPUT -p tcp --dport 137:139 -j ACCEPT
iptables -A INPUT -p udp --dport 137:139 -j ACCEPT
iptables -A INPUT -p tcp --dport 445 -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p udp --dport 137 -j ACCEPT
iptables -A INPUT -p udp --dport 138 -j ACCEPT
iptables -A INPUT -p tcp --dport 139 -j ACCEPT
iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
iptables -A INPUT -j REJECT --reject-with icmp-proto-unreachabl

echo "Liberando Samba Compartilhamento do Samba"
echo "On......................................................[#OK]"

###################
##Libera o Apache##
###################

echo "Liberando o Apache"
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 8081 -j ACCEPT
iptables -A INPUT -p tcp --dport 8082 -j ACCEPT
iptables -A INPUT -p tcp --dport 8083 -j ACCEPT


####################### 
#Bloquear Back Orifice#
#######################

iptables -A INPUT -p tcp --dport 31337 -j DROP
iptables -A INPUT -p udp --dport 31337 -j DROP
 
echo "ativado o bloqueio a tentativa de ataque do tipo BACK-ORIFICE"
echo "ON .....................................................[#OK]"

#################
#Bloquear NetBus#
#################

iptables -A INPUT -p tcp --dport 12345:12346 -j DROP
iptables -A INPUT -p udp --dport 12345:12346 -j DROP

echo "ativado o bloqueio a tentativa de ataque do tipo NET-BUS"
echo "ON .....................................................[#OK]"
##########################
#S#alvando Configurações##
##########################
iptables-save > /etc/webmin/firewall/iptables.save
iptables-restore < /etc/webmin/firewall/iptables.save

echo "Salvando todas as Configurações"
echo "ON .....................................................[#OK]"
################
##TITULO FECHA##
################

echo "Configuracao Firewall Concluida."
echo
echo "==========================================================|"
echo "::TERMINADA A CONFIGURACAO FIREWALL NETFILTER ATRAVES   ::|"
echo "::                  DO IPTABLES                         ::|"
echo "==========================================================|"
echo "FIREWALL ATIVADO - SISTEMA PREPARADO"
echo "SCRIPT DE FIREWALL CRIADO POR :-)  :-)"
echo "FIREWALL DESCARREGADO - SISTEMA LIBERADO"
