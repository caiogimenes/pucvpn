#!/bin/bash
NUMBEROFCLIENTS=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep -c "^V")
if [[ $NUMBEROFCLIENTS == '0' ]]; then
        echo ""
        echo "Nao ha usuarios para revogar"
        exit 1
fi

echo ""

CLIENT=$1
cd /etc/openvpn/easy-rsa/ || return
./easyrsa --batch revoke "$CLIENT"
EASYRSA_CRL_DAYS=3650 ./easyrsa gen-crl
rm -f /etc/openvpn/crl.pem
cp /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn/crl.pem
chmod 644 /etc/openvpn/crl.pem
find /home/ -maxdepth 2 -name "$CLIENT.ovpn" -delete
rm -f "/root/$CLIENT.ovpn"
sed -i "/^$CLIENT,.*/d" /etc/openvpn/ipp.txt
echo ""
echo "Certificado para o $CLIENT revogado."
cp /etc/openvpn/easy-rsa/pki/index.txt{,.bk}