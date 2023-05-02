#!/bin/bash
# Verifica o numero de clientes cadastrados atraves do arquivo index.txt
NUMBEROFCLIENTS=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep -c "^V")
if [[ $NUMBEROFCLIENTS == '0' ]]; then
        echo ""
        # Retorna ao usuario caso nao haja clientes cadastrados
        echo "Nao ha usuarios para revogar"
        exit 1
fi

echo ""
# Insere a variavel CLIENT o argumento passado pelo usuario
CLIENT=$1
# Muda o diretorio para onde se encontram a estrutura de chaves
cd /etc/openvpn/easy-rsa/ || return
# Executa o comando do easy-rsa para revogar certificado e tem argumento CLIENT
./easyrsa --batch revoke "$CLIENT"
# Atualiza o arquivo que contem os certificados revogados (certificate revoke list - crl)
EASYRSA_CRL_DAYS=3650 ./easyrsa gen-crl
# Remove o arquivo gerado anterior de crl
rm -f /etc/openvpn/crl.pem
# Copia o arquivo de crl novo gerado pelo comando gen-crl
cp /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn/crl.pem
# Altera permissão para leitura (todos)
chmod 644 /etc/openvpn/crl.pem
# Procura por todos os arquivos .ovpn do cliente e deleta
find /home/ -maxdepth 2 -name "$CLIENT.ovpn" -delete
rm -f "/root/$CLIENT.ovpn"
# Insere a informacao de revogacao do certificado no aquivo ipp
sed -i "/^$CLIENT,.*/d" /etc/openvpn/ipp.txt
echo ""
# Retorna ao usuario a mensagem final
echo "Certificado para o $CLIENT revogado."
# Atualiza o arquivo index.txt
cp /etc/openvpn/easy-rsa/pki/index.txt{,.bk}