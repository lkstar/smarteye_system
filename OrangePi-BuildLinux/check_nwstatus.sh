# !/bin/sh

echo "[leds-Power Up] RedLed: light GreenLed: close -> power up ok."
echo "[leds-Boot  Ok] RedLed: close GreenLed: light -> system boot ok."

echo "[leds-NW Stats] RedLed: flash GreenLed: flash -> network not connect."
echo "[leds-NW Stats] RedLed: flash GreenLed: light -> network connected."
echo "[leds-NW Stats] RedLed: light GreenLed: light -> connect to Internet."


while true
do
	nw_ip=`ifconfig | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}'| tr -d "addr:"`
	if [ ! $nw_ip ] ; then
		echo 0 > /sys/class/leds/red_led/brightness
		echo 1 > /sys/class/leds/green_led/brightness
		sleep 1
		echo 1 > /sys/class/leds/red_led/brightness
		echo 0 > /sys/class/leds/green_led/brightness
		sleep 1
		continue
	else
		echo 1 > /sys/class/leds/red_led/brightness
		#netstat=$(ping -c 3 www.baidu.com | grep transmitted | awk '{print $4}')
		#if [ "$netstat" != "3" ] ; then
		netstat=`wget --spider --timeout=10 --tries=1 --retry-connrefused --no-cache www.baidu.com 2>&1 | grep response | grep "200 OK"`
		if [ ! $netstat ] ; then
			echo 1 > /sys/class/leds/green_led/brightness
			sleep 1
			echo 0 > /sys/class/leds/green_led/brightness
			sleep 1
			continue
		fi
		echo 1 > /sys/class/leds/green_led/brightness

		lastip=`ifconfig | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}'| tr -d "addr:" | awk -F '.' '{print $4}'`
		if [ "$lastip" != "250" ] ; then
			currentip=`ifconfig | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}'| tr -d "addr:" | awk -F '.' '{print $1"."$2"."$3".250"}'`
			ifconfig $iface $currentip
			sleep 1
			iface=`ifconfig | grep -e ^w -e ^W | awk '{print $1}'`
			dhclient $iface
		fi
	fi

	sleep 120
done
