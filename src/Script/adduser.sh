#!/bin/bash

# Infos do cliente
CLIENT=$1
EMAIL=$2
COUNTRY=$3
STATE=$4
LOCAL=$5
ORGANIZATION=$6
UNIT=$7
COMMON=$8
PASS=1
# Fim das info do cliente

# Comando para verificar existencia de ceritificados ativos com nome CLIENT
CLIENTEXISTS=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep "^V" | grep -c -E "/CN=$CLIENT\$")
# Caso exista, informa que o nome ja existe
if [[ $CLIENTEXISTS == '1' ]]; then
	echo ""
	echo "Esse nome de cliente ja existe."
	exit
# Caso nao exista, executa esse codigo
else
	# Muda para o diretorio onde estao armazenadas a estrutura de chaves
	cd /etc/openvpn/easy-rsa/ || return
	# Cria um arquivo que armazena as variveis solicitadas do cliente
	touch pki/$CLIENT.vars
	# Insere no arquivo as variaveis do cliente
	echo "set_var EASYRSA_REQ_COUNTRY    '$COUNTRY'
set_var EASYRSA_REQ_PROVINCE   '$STATE'
set_var EASYRSA_REQ_CITY       '$LOCAL'
set_var EASYRSA_REQ_ORG        '$ORGANIZATION'
set_var EASYRSA_REQ_EMAIL      '$EMAIL'
set_var EASYRSA_REQ_OU         '$UNIT' ">/etc/openvpn/easy-rsa/pki/$CLIENT.vars
	# Comando do easy-rsa para criar certificado do cliente
	./easyrsa --batch --vars=/etc/openvpn/easy-rsa/pki/$CLIENT.vars build-client-full "$CLIENT" nopass
	# Informa que o cliente foi criado
	echo "Cliente $CLIENT criado."
fi
# Verifica em qual diretorio sera armazenado o arquivo .ovpn
# dependendo do usuario que executa o codigo
if [ -e "/home/${CLIENT}" ]; then
	homeDir="/home/${CLIENT}"
elif [ "${SUDO_USER}" ]; then
	if [ "${SUDO_USER}" == "root" ]; then
		homeDir="/root"
	else
		homeDir="/home/${SUDO_USER}"
	fi
else
	homeDir="/root"
fi
# Define o tipo de segurança a ser utilizada para o certificado, TLS-CRYPT ou TLS-AUTH
if grep -qs "^tls-crypt" /etc/openvpn/server.conf; then
	TLS_SIG="1"
elif grep -qs "^tls-auth" /etc/openvpn/server.conf; then
	TLS_SIG="2"
fi

# Gerar certificado .ovpn
# Copia o arquivo template do certificado e renomeia para CLIENT.ovpn
cp /etc/openvpn/client-template.txt "$homeDir/$CLIENT.ovpn"
{
	# Insere no arquivo template o diretorio do ca.crt
	echo "<ca>"
	cat "/etc/openvpn/easy-rsa/pki/ca.crt"
	echo "</ca>"
	# Insere no arquivo template o diretorio do CLIENT.crt gerado pelo comando do easy-rsa
	echo "<cert>"
	awk '/BEGIN/,/END CERTIFICATE/' "/etc/openvpn/easy-rsa/pki/issued/$CLIENT.crt"
	echo "</cert>"
	# Insere no arquivo template o diretorio do CLIENT.key gerado pelo comando do easy-rsa
	echo "<key>"
	cat "/etc/openvpn/easy-rsa/pki/private/$CLIENT.key"
	echo "</key>"
	# Insere no arquivo template o diretorio o tipo de autenticação de chave utilizada
	case $TLS_SIG in
	1)
		echo "<tls-crypt>"
		cat /etc/openvpn/tls-crypt.key
		echo "</tls-crypt>"
		;;
	2)
		echo "key-direction 1"
		echo "<tls-auth>"
		cat /etc/openvpn/tls-auth.key
		echo "</tls-auth>"
		;;
	esac
#Escreve no arquivo do cliente
} >>"$homeDir/$CLIENT.ovpn"
echo ""
# Informa onde se encontra o arquivo .ovpn do cliente
echo "O arquivo de configuração está em $homeDir/$CLIENT.ovpn."

exit 0
