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

echo "port 11940
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
log-append /var/log/openvpn/openvpn.log
verb 4
mute 10
explicit-exit-notify 1
--push \"redirect-gateway\"
user nobody
group nobody" >> /etc/openvpn/server.conf

var1=$(ip route | grep '^default' | awk '{print $5}')
var2=$(ip addr | grep $var1 | grep inet | awk '{print $2}' | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)")
var3=$(cat /etc/openvpn/ca.crt)
var4=$(cat /etc/openvpn/ta.key)
echo "client
dev tun
proto udp
remote $var2 11940
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-GCM
verb 3

<ca>
$var3
</ca>
key-direction 1
<tls-auth>
$var4
</tls-auth>" >> /etc/openvpn/example.ovpn

systemctl start openvpn@server
mkdir /etc/openvpn/clients

iptables -t nat -A POSTROUTING -o $var1 -j MASQUERADE