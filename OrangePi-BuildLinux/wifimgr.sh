#!/bin/sh

# From wlanconfig:
# $FreeBSD: src/usr.sbin/bsdinstall/scripts/wlanconfig,v 1.3.2.1 $

#
# Author: gihnius@gmail.com
#

####################################################################
usage () {
    cat <<EOF
Usage:
$0               Using the default wifi.
$0 -C name pass  connect wifi name:wifi name pass: wifi passwd.
$0 -l/list       use saved configured network, do not scan. So make sure the AP exist.
$0 stop          stop wifi connection
#$0 reconfig      re-configure device
#$0 newconf       create new /etc/wpa_supplicant.conf
#$0 addif         if not set rc.conf wlan configure; means does not exist $iface currently.
#$0 ns 127.0.0.1  set this nameserver
$0 help/-h/--help
EOF
    exit 0
}

check_network () {
    local _ssid=$1
    local _id=`wpa_cli -i $iface list_networks | awk '$2~/^'"$_ssid"'$/{print $1}' | head -1`
    if [ -z $_id ] ; then
        echo -1
    else
        echo $_id
    fi
}

update_psk () {
    local _ssid=$1
    local _psk=$2
    if [ ${#_psk} -lt 8 ] ; then
        echo psk length max be 8..63
        exit 1
    fi
    local _id=`check_network "$_ssid"`
    local _pass=`wpa_passphrase $_ssid $_psk | sed -n 's/[^#]psk=\(.*\)/\1/p'`
    wpa_cli -i $iface set_network $_id psk $_pass
}

stop_wifi () {
    ifconfig $iface down delete
    exit 0
}

cfg_dev () {
    ifconfig $iface create wlandev $phy_iface
    ifconfig $iface up
    /etc/rc.d/wpa_supplicant start $iface
}

recfg_dev () {
    ifconfig $iface down delete
    ifconfig $iface destroy
    ifconfig $phy_iface down
    ifconfig $phy_iface up
    ifconfig $iface create wlandev $phy_iface
    ifconfig $iface up
}

wpa_lookup () {
# Try to reach wpa_supplicant. If it isn't running and we can modify the
# existing system, start it. Otherwise, fail.
# Here use the existing system script /etc/rc.d/wpa_supplicant
    (wpa_cli -i $iface ping >/dev/null 2>/dev/null ||	/etc/rc.d/wpa_supplicant start $iface) || \
	    (dialog --backtitle "FreeBSD Wifi" --title "Error" --msgbox \
	    "Could not start wpa_supplicant!" 0 0; exit 1) || exit 1

# See if we succeeded
    wpa_cli -i $iface ping >/dev/null 2>/dev/null
    if [ $? -ne 0 ] ; then
	    dialog --backtitle "FreeBSD Wifi" --title "Error" --msgbox \
	        "Wireless cannot be configured without making changes to the local system!" \ 0 0
	    exit 1
    fi
}

final () {
    local nw=$1
    local nid=$2
    wpa_cli -i $iface disconnect
    ifconfig $iface ssid $nw
    wpa_cli -i $iface select_network $nid
    wpa_cli -i $iface enable_network $nid
    wpa_cli -i $iface reconnect
    wpa_cli -i $iface save_config
    sleep 2 
    dhclient $iface

	#exit 0
}

use_wificfg () {
    if [ -f $wpa_supplicant_conf ] ; then
        if [ $use_conf = 1 ] ; then
            # using wificfg
            return 0
        else
            echo "Backup $wpa_supplicant_conf ..."
            mv $wpa_supplicant_conf ${wpa_supplicant_conf}.old
            return 1
        fi
    else
        # can use wificfg
        return 1
    fi
}


auto_connect_default_wifi() {
    wName1=byxlk-server
    wPass1=20060806
    wName2=ligang
    wPass2=12345678
    wName3=MERCURY_9D6706
    wPass3=iamok_007
    wName4=FAST_602
    wPass4=iamok_007
    wName5=TP-LINK_F3DE
    wPass5=13918614265
    wName6=test6
    wPass6=12345678
    flag=0

    wpa_lookup
    wpa_cli -i $iface ap_scan 1 
    wpa_cli -i $iface scan 

    SCAN_RESULTS=`wpa_cli -i $iface scan_results`
    sleep 1
    SCAN_WIFI=`echo "$SCAN_RESULTS" | awk -F '\t' \
    '/..:..:..:..:..:../ {printf "%s\n",$NF }'`
    echo "$SCAN_WIFI" | grep -q "$wName1"
    if [ $? -eq 0 ]; then
        CurrentWifi=$wName1
        CurrentPass=$wPass1
        flag=1
        echo "Connect wireless $CurrentWifi, PLS wait..."
    fi
	
    echo "$SCAN_WIFI" | grep -q "$wName2"
    if [ $? -eq 0 ]; then
        CurrentWifi=$wName2
        CurrentPass=$wPass2
        flag=1
        echo "Connect wireless $CurrentWifi, PLS wait..."
    fi
    
    echo "$SCAN_WIFI" | grep -q "$wName3"
    if [ $? -eq 0 ]; then
        CurrentWifi=$wName3
        CurrentPass=$wPass3
        flag=1
        echo "Connect wireless $CurrentWifi, PLS wait..."
    fi
    
    echo "$SCAN_WIFI" | grep -q "$wName4"
    if [ $? -eq 0 ]; then
        CurrentWifi=$wName4
        CurrentPass=$wPass4
        flag=1
        echo "Connect wireless $CurrentWifi, PLS wait..."
    fi

    echo "$SCAN_WIFI" | grep -q "$wName5"
    if [ $? -eq 0 ]; then
        CurrentWifi=$wName5
        CurrentPass=$wPass5
        flag=1
        echo "Connect wireless $CurrentWifi, PLS wait..."
    fi

    echo "$SCAN_WIFI" | grep -q "$wName6"
    if [ $? -eq 0 ]; then
        CurrentWifi=$wName6
        CurrentPass=$wPass6
        flag=1
        echo "Connect wireless $CurrentWifi, PLS wait..."
    fi

    if [ $flag -ne 1 ]; then
        echo "Please configure the default WiFi information..."
        exit 0
    fi

    current_id=`wpa_cli -i $iface add_network | tail -1`
    wpa_cli -i $iface set_network $current_id ssid "\"$CurrentWifi\""
    update_psk "$CurrentWifi" "$CurrentPass"

    echo "[Debug Info] SSID: $CurrentWifi PW: $CurrentPass Index: $current_id"
    final $CurrentWifi $current_id

    #exit 0

}
##################################################################################
# get wifi device name  wlan
iface=`ifconfig | grep -e ^w -e ^W | awk '{print $1}'`
if ifconfig $iface >/dev/null 2>&1 ; then
	echo "Find wifi device:$iface"
else
	echo "not find wifi device, exit!"
	exit 0;
fi

# driver device
dev=$iface
if ifconfig $dev >/dev/null 2>&1 ; then
    phy_iface=$dev
else
    phy_iface=ath0
fi

# use system wpa_supplicant.conf
wpa_supplicant_conf=/etc/wpa_supplicant.conf

# network id -1 non exist
current_id=-1

# use default wpa_supplicant.conf
use_conf=1

# check input paras
if [ $# -eq 0 ]; then
    echo "Using the default configuration..."
    auto_connect_default_wifi
	currentip=`ifconfig | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}'| tr -d "addr:" | awk -F '.' '{print $1"."$2"."$3".250"}'`
	ifconfig $iface $currentip
	sleep 1
	dhclient $iface
	ifconfig | grep Mask | grep -v 127.0.0.1 | awk '{print $2"  "$3"  "$4}'
	exit 0
fi

# input paras parse
case $1 in
    -C)
        if [ $# -ne 3 ];
        then
            echo "Input format error, please view the help!"
            usage
            exit 0
        fi
        wifiName=$2
        wifiPass=$3
        ;;
    stop)
        stop_wifi ;;
    -l|list)
        wpa_lookup
        wpa_cli -i $iface list
        echo "Please enter the network id:"
        read current_id
        if [ $current_id -lt 0 -o $current_id -ge 64 ] ; then
            # too small or too big try again
            wpa_cli -i $iface list
            echo "Please enter the network id:"
            read current_id
        fi
        NETWORK=`wpa_cli -i $iface list | awk '{if($1=='"$current_id"'){print $2}}'`
        final $NETWORK $current_id
		exit 0
        ;;
#    reconfig)
#        recfg_dev
#        exit 0
#        ;;
#    newconf)
#        use_conf=0 ;;
#    addif)
#        cfg_dev ;;
#    ns)
#        if [ ! -z $2 ] ; then
#            if ! grep -q $2 /etc/resolv.conf ; then
#                echo $2 >> /etc/resolv.conf
#            fi
#        fi
#        ;;
    -h|--help|help)
        usage ;;
esac


if use_wificfg ; then
    echo "Using $wpa_supplicant_conf ."
else
    echo -n > $wpa_supplicant_conf
    chmod 0600 $wpa_supplicant_conf
    echo "ctrl_interface=/var/run/wpa_supplicant" >> $wpa_supplicant_conf
    echo "eapol_version=2" >> $wpa_supplicant_conf
    echo "fast_reauth=1" >> $wpa_supplicant_conf
    echo "update_config=1" >> $wpa_supplicant_conf
    echo >> $wpa_supplicant_conf
fi

## progress ...

wpa_lookup
wpa_cli -i $iface ap_scan 1
wpa_cli -i $iface scan

SCAN_RESULTS=`wpa_cli -i $iface scan_results`
sleep 1
SCAN_WIFI=`echo "$SCAN_RESULTS" | awk -F '\t' \
        '/..:..:..:..:..:../ {printf "%s\n",$NF }'`
echo "$SCAN_WIFI" | grep -q "$wifiName"
if [ $? -eq 0 ]; then
    echo "Connect wireless $wifiName, PLS wait..."
else
    echo "No wireless networks were found."
    exit 0
fi

#NETWORKS=`echo "$SCAN_RESULTS" | awk -F '\t' \
#    '/..:..:..:..:..:../ {if (length($5) > 0) printf("\"%s\"\t%s\n", $5, $4);}' |
#    sort | uniq`
#echo "+++DBG: NETWORKS end"

#if [ -z "$NETWORKS" ] ; then
#	dialog --backtitle "FreeBSD Wifi" --title "Error" \
#	    --yesno "No wireless networks were found. Rescan?" 0 0 && \
#	    exec $0 $@
#	exit 1
#fi


#current_id=`check_network "$wifiName"`
#if [ $current_id -ge 0 ] ; then
#    echo "Connect to Network $wifiName"
#    final $wifiName $current_id
#fi

current_id=`wpa_cli -i $iface add_network | tail -1`
wpa_cli -i $iface set_network $current_id ssid "\"$wifiName\""
update_psk "$wifiName" "$wifiPass"

echo "Debug: SSID: $wifiName PW: $wifiPass  Index: $current_id"
final $wifiName $current_id

exit 0
##################### End #######################
