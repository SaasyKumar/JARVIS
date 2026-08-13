INTERFACE=$(route get default 2>/dev/null | awk '/interface:/{print $2}')

VPN_STATUS="${BRed}DISCONNECTED${Color_Off}"

if [[ "$INTERFACE" == utun* || "$INTERFACE" == ppp* ]]; then
    VPN_STATUS="${BIGreen}CONNECTED${Color_Off}"
fi
