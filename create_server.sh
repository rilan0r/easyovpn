apt update
apt install openvpn easy-rsa -y
mkdir /etc/openvpn/easy-rsa
cp -R /usr/share/easy-rsa /etc/openvpn
cd /etc/openvpn/easy-rsa/
./easyrsa init-pki
./easyrsa build-ca
./easyrsa gen-dh
openvpn --genkey --secret ta.key
cp ta.key /etc/openvpn/ta.key
mv ta.key pki/ta.key
./easyrsa gen-crl
./easyrsa build-server-full server nopass
cp ./pki/ca.crt /etc/openvpn/ca.crt
cp ./pki/dh.pem /etc/openvpn/dh.pem
cp ./pki/crl.pem /etc/openvpn/crl.pem
cp ./pki/issued/server.crt /etc/openvpn/server.crt
cp ./pki/private/server.key /etc/openvpn/server.key
sysctl -w net.ipv4.ip_forward=1

echo "port 1194
dev tun
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh.pem
topology subnet
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist /var/log/openvpn/ipp.txt
keepalive 10 120
tls-auth /etc/openvpn/ta.key 0
cipher AES-256-GCM
persist-key
persist-tun
status /var/log/openvpn/openvpn-status.log
log /var/log/openvpn/openvpn.log
verb 4
mute 10
explicit-exit-notify 1
--push \"redirect-gateway\"" >> /etc/openvpn/server.conf

var1=$(hostname -I)
var2=$(cat /etc/openvpn/ca.crt)
var3=$(cat /etc/openvpn/ta.key)
echo "client
dev tun
proto udp
remote $var1 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
verb 3

<ca>
$var2
</ca>
key-direction 1
<tls-auth>
$var3
</tls-auth>" >> /etc/openvpn/example.ovpn

systemctl start openvpn@server
mkdir /etc/openvpn/clients

var4=$(route | grep '^default' | grep -o '[^ ]*$')
iptables -t nat -A POSTROUTING -o $var4 -j MASQUERADE