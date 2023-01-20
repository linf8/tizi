#!/bin/bash
# one key vless

apt update && apt install qrencode wget unzip -y
rm -rf xray cloudflared-linux-amd64
wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x cloudflared-linux-amd64
unzip -d xray Xray-linux-64.zip
rm -rf Xray-linux-64.zip
cat>xray/config.json<<EOF
{
    "log": {
        "loglevel": "none"
    },
    "inbounds": [
        {
            "port": 23333,
            "listen": "127.0.0.1",
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "ffffffff-ffff-ffff-ffff-ffffffffffff", 
                        "level": 0,
                        "email": "fck@gfw"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "wsSettings": {
                    "path": "/shansir2023" 
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
    ]
}
EOF
kill -n 9 $(ps -ef | grep xray | grep -v grep | awk '{print $2}')
kill -n 9 $(ps -ef | grep cloudflared-linux-amd64 | grep -v grep | awk '{print $2}')
./xray/xray run -config ./xray/config.json &
./cloudflared-linux-amd64 tunnel --url http://localhost:23333 --no-autoupdate >argo.log 2>&1 &
sleep 2
echo "waiting for cloudflare argo address"
sleep 10
argo=$(cat argo.log | grep trycloudflare.com | awk 'NR==2{print}' | awk -F// '{print $2}' | awk '{print $1}')
clear
url='vless://ffffffff-ffff-ffff-ffff-ffffffffffff@45.64.22.6:443?encryption=none&security=tls&type=ws&host='$argo'&path=%2fshansir2023#argo+vless'
echo $url | qrencode -t UTF8
echo $url
