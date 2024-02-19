#!/bin/bash

echo "Trying to install wgToggler..."

if [ "$USER" != "root" ]
then
    echo "Run this script under root!"
    exit 1
fi

WG_CONFS=("$(ls /etc/wireguard/)")

INTERFACE_NAME=""

for WG_CONF in "${WG_CONFS[@]}"
do
    NAME="$(echo "$WG_CONF" | cut -d '.' -f1)"
    EXT="$(echo "$WG_CONF" | cut -d '.' -f2)"
    if [ "$EXT" == "conf" ]
    then
        INTERFACE_NAME="$NAME"
        break
    fi
done

if [ -z "$INTERFACE_NAME" ]
then
    echo "No wireguard confs were found!"
    exit 1
fi

SCRIPT_DIR="$(dirname "$0")"
INSTALL_DIR="/home/$SUDO_USER/.wgToggle/"
ICONS_DIR="/home/$SUDO_USER/.local/share/icons"
APP_DIR="/home/$SUDO_USER/.local/share/applications"

echo -n "Copying files... "
mkdir -p "$INSTALL_DIR" >> /dev/null 2>&1
cp   "$SCRIPT_DIR/uninstall.sh" "$INSTALL_DIR"
cp   "$SCRIPT_DIR/wgToggle"     "$INSTALL_DIR"
cp   "$SCRIPT_DIR/WG_CON.ico"   "$ICONS_DIR"
cp   "$SCRIPT_DIR/WG_DIS.ico"   "$ICONS_DIR"
cp   "$SCRIPT_DIR/WG_OK.ico"    "$ICONS_DIR"
cp   "$SCRIPT_DIR/WG_ERR.ico"   "$ICONS_DIR"
echo "$INTERFACE_NAME" >        "$INSTALL_DIR/interface"
echo "Done"

echo -n "Setting up icon... "
ip -br a | grep -oq "$INTERFACE_NAME"
if [ $? == 0 ]
then
    ICON="$ICONS_DIR/WG_DIS.ico"
else
    ICON="$ICONS_DIR/WG_CON.ico"
fi
echo "Done"

echo -n "Setting up .desktop file... "
cp "$SCRIPT_DIR/wgToggle.desktop" "$SCRIPT_DIR/wgToggle.desktop.tmp"
sed -i 's|^Exec=.*|Exec='"$INSTALL_DIR/wgToggle"'|' "$SCRIPT_DIR/wgToggle.desktop.tmp"
sed -i 's|^Icon=.*|Icon='"$ICON"'|' "$SCRIPT_DIR/wgToggle.desktop.tmp"
mv "$SCRIPT_DIR/wgToggle.desktop.tmp" "$APP_DIR/wgToggle.desktop"
echo "Done"

echo -n "Restoring owner of files... "
chown -R "$SUDO_USER":"$SUDO_USER" "$INSTALL_DIR"
chown    "$SUDO_USER":"$SUDO_USER" "$ICONS_DIR/WG_CON.ico" "$ICONS_DIR/WG_DIS.ico" "$ICONS_DIR/WG_OK.ico" "$ICONS_DIR/WG_ERR.ico"
chown -R "$SUDO_USER":"$SUDO_USER" "$APP_DIR/wgToggle.desktop"
echo "Done"

echo "Installation is complete!"

exit 0
