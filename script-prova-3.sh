#!/bin/bash
#
#
#
##Script para correção de avaliação Redes Locais. 3 avaliacao.
##Elaboração Raphael H. Moretti raphaelhmoretti@gmail.com 
##e Sandro Melo c4ri0c4.ninjj@gmail.com
#
##Versao 1.0
#
#Para sua execução, certifique-se de possuir as suites nmap, ssh e ftp!
#
#
#
# Para a utilização deste Script, execute com os parametros IP do aluno
# (Ex: ./script-prova-3.sh <ip-aluno>)
# Para seu funcionamento, é necessário a instalação da suite NMAP
#
#
## O objetivo deste script é efetuar a correção 
## avaliação dos alunos
## do 3 semestre de redes.
#
#
#
#
# A funcao Status retorna se o Host responde a ICMP ou nao

func_status()
{
	echo "Verificando se o Host $1 está UP ou Down"
IP=$1
ALUNO=$2
IPSERVER=$3
	ping -c 3 $IP >> /dev/null && echo "Host UP" && func_sshport || func_dna
}
# func_dna = Funcao "Do not Asnwer". 

func_dna()
{
	echo "O Host $IP não responde"; echo "A maquina Virtual do aluno $ALUNO do endereço $IP não respondeu a ICMP"
}


# Verifica em qual Porta o SSH está trabalhando

func_sshport()
{
	echo "#####################################"
	echo "Verificando a porta da qual SSH está ativo (22 ou 12345)"
	echo "Questão 1 "
	
NMAP=`which nmap`
SSH_22=`$NMAP $IP -p 22 | grep 22 | cut -f2 -d " " | grep o`
SSH_12345=`$NMAP $IP -p 12345 | grep 12345 | cut -f2 -d " " | grep o`
[ "$SSH_22" == "open" ]   
	if [ $? == 0 ]; then
	PORT=22
	else  
	[ "$SSH_12345" == "open" ]
		if [ $? == 0 ]; then
		PORT=12345
		else
		echo "SSH não ativo nas portas 22 e 12345"
		echo "Aluno $ALUNO do IP $IP não possui SSH ativo nas portas citadas" > ./"$ALUNO"_"$IP" 
	exit
	fi
fi

	echo "SSH ativo na porta $PORT"
}

# Verifica o funcionamento das chave SSH publicada para acesso sem senha

func_sshkeys()
{
	echo "########################################"
	echo "Questão 2"

	ssh -p $PORT -o BatchMode=yes root@$IP exit 2>&1 > /dev/null
	[ $? == 0 ] && echo "SSH Funcionandor normalmente em root" || func_zero 
}
# Caso nao funcione a autenticacao via chaves, chama a funcao func_zero()

func_zero()
{
	echo "Nao foi possivel conectar via chaves no SSH pela conta root"
	echo "O aluno $ALUNO do ip $IP não conseguiu fazer autenticacao via chaves"
	exit
}


#Verifica o funcionamento das entradas DNS requisitadas ao aluno

func_DNS()
{
	echo "#"
	echo "Questão 3"
	cp /etc/resolv.conf /etc/resolv.conf.bkp 2>&1>/dev/null
	echo "nameserver $IP" >> /etc/resolv.conf

		for DNS in "prova.bandtec.xxx.br" "semestral.bandtec.xxx.br" "anonymous.bandtec.xxx.br" "ftp.bandtec.xxx.br"; do

		ping -c3 $DNS > /dev/null
		[ $? == 0 ] && echo "Entrada $DNS presente" || echo "Entrada $DNS não presente"
		done
	cp /etc/resolv.conf.bkp /etc/resolv.conf 2>&1>/dev/null
	rm resolv.conf 2>&-
}


#Verificar a funcionalidade do ftp anonymous

func_FTP()
{
	echo "#"
	echo "Questao 4"

	echo "user anonymous senha@senha.com" >>cmdftp.temp
	echo "bye" >> cmdftp.temp

FTP=`ftp -nv $IP < ./cmdftp.temp`


	echo $FTP | grep 230 > /dev/null

        [ $? == 0 ] && echo "OK, anonymous funcionando" || echo "Nao ok"

	rm ./cmdftp.temp 2>&1-
}


# Verifica a funcionalidade do virtual Hosts

func_vhosts()
{
	echo "#"
	echo "Questão 5"
        
	for DOMAIN in "prova.bandtec.xxx.br" "semestral.bandtec.xxx.br" ; do
        	wget $DOMAIN -O /dev/null 2>&- 
                	
		[ $? != 0 ] && echo "Dominio $DOMAIN NAO configurado virtualhost" || echo "Dominio $DOMAIN configurado virtualhost"

        done

}


# Verifica a funcionalidade dos módulos do apache status e info

func_mods()
{
	echo "#"
	echo "Questao 6"
        
	for MODS in "status.conf" "info.conf"; do
        	
		scp -o "BatchMode yes" -P $PORT root@$IP:/etc/apache2/mods-enabled/$MODS ./ 2>&1> /dev/null

	        [ $? == 0 ] && echo "Modulo $MODS ativado" || echo "Modulo $MODS desativado"
	done
	rm status.conf info.conf 2>&- 

}


func_status $1
func_sshkeys
func_DNS
func_FTP
func_vhosts
func_mods
