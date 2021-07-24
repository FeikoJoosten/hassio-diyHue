#!/usr/bin/with-contenv bashio

CONFIG_PATH=/data/options.json

export MAC="$(bashio::config 'mac')"
export CONFIG_PATH="$(bashio::config 'config_path')"
export DEBUG="$(bashio::config 'debug')"

if [[ ! -z "$(bashio::config 'deconz_ip')" ]]; then
    export DECONZ="$(bashio::config 'deconz_ip')"
fi

export NO_SERVE_HTTPS="$(bashio::config 'no_serve_https')"

if [[ -d $CONFIG_PATH ]]; then
    echo "$CONFIG_PATH exists."
else
    mkdir -p $CONFIG_PATH
    echo "$CONFIG_PATH created."
fi

echo -e "\033[33m--Setting up diyHue--\033[0m" 

if [ -f "/opt/hue-emulator/export/cert.pem" ]; then
    echo -e "\033[33m--Restoring certificate--\033[0m"
    cp /opt/hue-emulator/export/cert.pem /opt/hue-emulator/cert.pem
    echo -e "\033[33m--Certificate restored--\033[0m"
else
    echo -e "\033[33m--Generating certificate--\033[0m"
    /opt/hue-emulator/genCert.sh $mac
    cp /opt/hue-emulator/cert.pem /opt/hue-emulator/export/cert.pem
    echo -e "\033[33m--Certificate created--\033[0m"
fi

if [ -f "/opt/hue-emulator/export/config.json" ]; then
    echo -e "\033[33m--Restoring config--\033[0m" 
    cp /opt/hue-emulator/export/config.json /opt/hue-emulator/config.json
    echo -e "\033[33m--Config restored--\033[0m" 
else
    echo -e "\033[33m--Downloading default config--\033[0m"
    curl -o /opt/hue-emulator/config.json https://raw.githubusercontent.com/mariusmotea/diyHue/master/BridgeEmulator/config.json
    cp /opt/hue-emulator/config.json /opt/hue-emulator/export/config.json
    echo -e "\033[33m--Config downloaded--\033[0m" 
fi


echo "Your Architecture is $BUILD_ARCHI"

if [ "$NO_SERVE_HTTPS" = "true" ] ; then
    echo "No serve HTTPS"
    python3 -u /opt/hue-emulator/HueEmulator3.py --docker --no-serve-https
else 
    echo "Serve HTTPS"
    python3 -u /opt/hue-emulator/HueEmulator3.py --docker
fi
