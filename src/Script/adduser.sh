#!/bin/bash

#Infos do cliente
CLIENT=$1
EMAIL=$2
COUNTRY=$3
STATE=$4
LOCAL=$5
ORGANIZATION=$6
UNIT=$7
COMMON=$8
PASS=1

#Comeco do codigo
CLIENTEXISTS=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep "^V" | grep -c -E "/CN=$CLIENT\$")
if [[ $CLIENTEXISTS == '1' ]]; then
	echo ""
	echo "Esse nome de cliente ja existe."
	exit
else
	cd /etc/openvpn/easy-rsa/ || return
	touch pki/$CLIENT.vars
	echo "set_var EASYRSA_REQ_COUNTRY    '$COUNTRY'
set_var EASYRSA_REQ_PROVINCE   '$STATE'
set_var EASYRSA_REQ_CITY       '$LOCAL'
set_var EASYRSA_REQ_ORG        '$ORGANIZATION'
set_var EASYRSA_REQ_EMAIL      '$EMAIL'
set_var EASYRSA_REQ_OU         '$UNIT' ">/etc/openvpn/easy-rsa/pki/$CLIENT.vars
	
	./easyrsa --batch --vars=/etc/openvpn/easy-rsa/pki/$CLIENT.vars build-client-full "$CLIENT" nopass
	echo "Cliente $CLIENT criado."
fi

# Diretorio do cliente a ser criado, onde ficarao as configuracoes
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

if grep -qs "^tls-crypt" /etc/openvpn/server.conf; then
	TLS_SIG="1"
elif grep -qs "^tls-auth" /etc/openvpn/server.conf; then
	TLS_SIG="2"
fi

# Gerar certificado .ovpn
cp /etc/openvpn/client-template.txt "$homeDir/$CLIENT.ovpn"
{
	echo "<ca>"
	cat "/etc/openvpn/easy-rsa/pki/ca.crt"
	echo "</ca>"

	echo "<cert>"
	awk '/BEGIN/,/END CERTIFICATE/' "/etc/openvpn/easy-rsa/pki/issued/$CLIENT.crt"
	echo "</cert>"

	echo "<key>"
	cat "/etc/openvpn/easy-rsa/pki/private/$CLIENT.key"
	echo "</key>"

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
} >>"$homeDir/$CLIENT.ovpn"

echo ""
echo "The configuration file has been written to $homeDir/$CLIENT.ovpn."
echo "Download the .ovpn file and import it in your OpenVPN client."

exit 0
