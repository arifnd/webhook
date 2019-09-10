#!/bin/bash

# must root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# if curl not installed
if ! [ -x "$(command -v curl)" ]; then
  echo 'Error: curl is not installed.' >&2
  exit 1
fi

ARCH=amd64
OS=linux
FOLDER_PATH=$(pwd)
SERVICE_PATH=/etc/systemd/system

# VERSION=2.6.9
# get version
echo -ne "Get lastest version..."
VERSION=$(curl --silent "https://api.github.com/repos/adnanh/webhook/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/')
echo "[DONE]"

FILE=webhook-$OS-$ARCH.tar.gz
FOLDER=webhook-$OS-$ARCH

# if file not exist
if [[ ! -f "$FILE" ]]; then
    echo -ne "Downloading..."
    /usr/bin/wget -q https://github.com/adnanh/webhook/releases/download/$VERSION/$FILE -O $FILE
    echo "[DONE]"
else
    echo "$FILE alredy exist"
fi

tar zxvf $FILE
cp -f $FOLDER/webhook .
rm -r $FOLDER $FILE

if [[ ! -f .env ]]; then
    cp .env-example .env
fi

# generate webhook.service
echo -ne "Generate systemd service..."
sed -e "s@PATH@$FOLDER_PATH@g" systemd-example.service > $SERVICE_PATH/webhook.service
echo "[DONE]"
echo -ne "Install systemd service..."
chmod +x $SERVICE_PATH/webhook.service
echo "[DONE]"
