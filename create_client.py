import subprocess
import sys
import argparse


def createParser():
    parser = argparse.ArgumentParser()
    parser.add_argument('name', nargs='?')

    return parser

def send_command(var):
    return subprocess.call(var, shell=True)


parser = createParser()
namespace = parser.parse_args()

if namespace.name:
    name = str(namespace.name)
    mk = f"mkdir /etc/openvpn/clients/{name}"
    send_command(mk)
    create_cert = f"/etc/openvpn/easy-rsa/easyrsa --pki-dir=/etc/openvpn/easy-rsa/pki/ build-client-full {name} nopass"
    send_command(create_cert)
    cp_ca = f"cp /etc/openvpn/easy-rsa/pki/ca.crt /etc/openvpn/clients/{name}/"
    cp_ta = f"cp /etc/openvpn/easy-rsa/pki/ta.key /etc/openvpn/clients/{name}/"
    cp_issued = f"cp /etc/openvpn/easy-rsa/pki/issued/{name}.crt /etc/openvpn/clients/{name}/"
    cp_private = f"cp /etc/openvpn/easy-rsa/pki/private/{name}.key /etc/openvpn/clients/{name}/"
    cp_ovpn = f"cp /etc/openvpn/example.ovpn /etc/openvpn/clients/{name}/{name}.ovpn"
    send_command(cp_ca)
    send_command(cp_ta)
    send_command(cp_issued)
    send_command(cp_private)
    send_command(cp_ovpn)

    client_cert_start = f"echo '<cert>' >> /etc/openvpn/clients/{name}/{name}.ovpn"
    send_command(client_cert_start)
    f = open(f"/etc/openvpn/clients/{name}/{name}.crt", 'r')
    client_cert = ""
    tmp = f.readlines()
    for line in tmp[64:]:
        client_cert += line
    f2 = open(f"/etc/openvpn/clients/{name}/{name}_tmp.crt", 'w')
    print(client_cert[:-1], file=f2)
    f.close()
    f2.close()
    cp_client_cert = f"cat /etc/openvpn/clients/{name}/{name}_tmp.crt >> /etc/openvpn/clients/{name}/{name}.ovpn"
    send_command(cp_client_cert)
    client_cert_end = f"echo '</cert>' >> /etc/openvpn/clients/{name}/{name}.ovpn"
    send_command(client_cert_end)

    client_key_start = f"echo '<key>' >> /etc/openvpn/clients/{name}/{name}.ovpn"
    cp_client_key = f"cat /etc/openvpn/clients/{name}/{name}.key >> /etc/openvpn/clients/{name}/{name}.ovpn"
    client_key_end = f"echo '</key>' >> /etc/openvpn/clients/{name}/{name}.ovpn"
    send_command(client_key_start)
    send_command(cp_client_key)
    send_command(client_key_end)
else:
    print("Enter the name of certificate owner")
