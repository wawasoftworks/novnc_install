#!/bin/bash

echo "
 ___       __   ________  ___       __   ________  ________  ________  ________ _________  ___       __   ________  ________  ___  __    ________  ___       
|\  \     |\  \|\   __  \|\  \     |\  \|\   __  \|\   ____\|\   __  \|\  _____\\___   ___\\  \     |\  \|\   __  \|\   __  \|\  \|\  \ |\   ____\|\  \      
\ \  \    \ \  \ \  \|\  \ \  \    \ \  \ \  \|\  \ \  \___|\ \  \|\  \ \  \__/\|___ \  \_\ \  \    \ \  \ \  \|\  \ \  \|\  \ \  \/  /|\ \  \___|\ \  \     
 \ \  \  __\ \  \ \   __  \ \  \  __\ \  \ \   __  \ \_____  \ \  \\\  \ \   __\    \ \  \ \ \  \  __\ \  \ \  \\\  \ \   _  _\ \   ___  \ \_____  \ \  \    
  \ \  \|\__\_\  \ \  \ \  \ \  \|\__\_\  \ \  \ \  \|____|\  \ \  \\\  \ \  \_|     \ \  \ \ \  \|\__\_\  \ \  \\\  \ \  \\  \\ \  \\ \  \|____|\  \ \__\   
   \ \____________\ \__\ \__\ \____________\ \__\ \__\____\_\  \ \_______\ \__\       \ \__\ \ \____________\ \_______\ \__\\ _\\ \__\\ \__\____\_\  \|__|   
    \|____________|\|__|\|__|\|____________|\|__|\|__|\_________\|_______|\|__|        \|__|  \|____________|\|_______|\|__|\|__|\|__| \|__|\_________\  ___ 
                                                     \|_________|                                                                          \|_________| |\__\
                                                                                                                                                        \|__|
                                                                                                                                                             
"

sleep 3

echo "enter the installation directory for noVNC(it can be anything):"
read INSTALL_DIR

if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR"
fi

echo "downloading noVNC latest version..."
curl -L https://github.com/novnc/noVNC/archive/refs/heads/master.tar.gz -o /tmp/novnc.tar.gz

echo "extracting noVNC to $INSTALL_DIR..."
tar -xzf /tmp/novnc.tar.gz -C "$INSTALL_DIR"

echo "checking for a desktop environment..."
if [ -n "$(which startxfce4)" ]; then
    DE=startxfce4
elif [ -n "$(which startkde)" ]; then
    DE=startkde
elif [ -n "$(which startlxde)" ]; then
    DE=startlxde
elif [ -n "$(which startlxqt)" ]; then
    DE=startlxqt
elif [ -n "$(which startgnome)" ]; then
    DE=startgnome
elif [ -n "$(which startplasma-x11)" ]; then
    DE=startplasma-x11
else
    echo "no desktop environment detected. do you want to install Fluxbox? (y/n)"
    read INSTALL_FLUXBOX
    if [ "$INSTALL_FLUXBOX" == "y" ]; then
        echo "installing..."
        sudo apt-get update
        sudo apt-get install -y fluxbox xinit
        DE=startfluxbox
    else
        echo "please install a desktop environment and run this script again."
        exit 1
    fi
fi

echo "installing TightVNC server..."
sudo apt-get update
sudo apt-get install -y tightvncserver

echo "starting VNC server and setting password..."
tightvncserver -kill :1 > /dev/null 2>&1
rm -rfv /tmp/.X1-lock > /dev/null 2>&1
tightvncserver -localhost :1

echo "starting desktop environment..."
echo "$DE" > ~/.xinitrc

echo "installing websockify..."
sudo apt-get install -y python3-setuptools python3-pip
sudo pip3 install jwcrypto websockify

echo "starting noVNC proxy..."
cd "$INSTALL_DIR/noVNC-master/utils"
bash novnc_proxy --vnc localhost:5901 --listen 6080
