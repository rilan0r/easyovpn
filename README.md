# EasyOVPN

With this short scripts you can easily deploy OpenVPN server, configure it, and create users to connect.

## Usage

```
git clone git@github.com:rilan0r/easyovpn.git
cd easyovpn/
sudo bash create_server.sh
```

For this script you'll need to create master password for you server's CA, and type it several times. After completing script it would install OpenVPN and make all required preparations.

`sudo python3 create-client.py username`

Instead of [username] type name of future OpenVPN user. After it script would ask you to type master password, which you created running first script. After completion you'll find at /etc/openvpn/clients/[username]/ files with user certificate, keys, and several others. You'll need [username].ovpn, it is ready to use, just copy it to device from which you'll connect to your OpenVPN server and start OpenVPN app.
