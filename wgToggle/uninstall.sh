#!/bin/bash

echo "Trying to uninstall wgToggler..."

if [ "$USER" != "root" ]
then
    echo "Run this script under root!"
    exit 1
fi

INTERFACE_NAME="$(cat "/home/$USER/.wgToggle/interface")"
if [ -z "$INTERFACE_NAME" ]
then
    echo "No wireguard confs were found!"
    exit 1
fi

INSTALL_DIR="/home/$SUDO_USER/.wgToggle/"
ICONS_DIR="/home/$SUDO_USER/.local/share/icons"
APP_DIR="/home/$SUDO_USER/.local/share/applications"

wg-quick down "$INTERFACE_NAME" >> /dev/null 2>&1

rm "$APP_DIR/wgToggle.desktop"
rm "$ICONS_DIR/WG_CON.ico" "$ICONS_DIR/WG_DIS.ico" "$ICONS_DIR/WG_OK.ico" "$ICONS_DIR/WG_ERR.ico"

rm -r "$INSTALL_DIR"

echo "Uninstallation is complete!"

exit 0
