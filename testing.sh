#!/bin/bash

function showOk {
	raspi-gpio set 17 dl
	raspi-gpio set 27 dl
	raspi-gpio set 22 dh
	echo "######"
	echo "All tests OK"
	echo "######"
}

function showFailed {
	raspi-gpio set 17 dh
	raspi-gpio set 27 dl
	raspi-gpio set 22 dl
	echo "######"
	echo "Tests FAILED"
	echo "######"
}

i2cDir="/sys/class/i2c-adapter/i2c-0"
i2cAddDevCmd="24c32 0x50"
i2cDev="0-0050"
testingDir="/home/pi/testing"
eepFile="rr_base.eep"
encDrvMsg="enc28j60 driver registered"

if [ "$(id -u)" -ne "0" ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

echo "Initializing tests"

# Initialize LEDs: Red Yellow Green => Low
raspi-gpio set 17 op
raspi-gpio set 27 op
raspi-gpio set 22 op

ping -c 1 -W 1 www.google.at &> /dev/null
if [ "$?" -ne "0" ]; then
	raspi-gpio set 17 dh
fi
raspi-gpio set 27 dh
raspi-gpio set 22 dh

# Initialize Button
raspi-gpio set 26 ip pu

# Debugging
#echo "0x50" > ${i2cDir}/delete_device

# Creating EEPROM device node
if [ ! -d "${i2cDir}/${i2cDev}" ]; then
	echo "Creating EEPROM device node"
	echo "${i2cAddDevCmd}" > ${i2cDir}/new_device
fi

# Visualize "Done initializing"
sleep 2
raspi-gpio set 17 dl
raspi-gpio set 27 dl

echo "Done initializing"
echo "Waiting for button pressed event"

while true; do
	buttonPressed=$(raspi-gpio get 26 | cut -d '=' -f 2 | cut -d ' ' -f 1)
	if [ "${buttonPressed}" -eq "0" ]; then
		startTime=${SECONDS}

		raspi-gpio set 17 dl
		raspi-gpio set 27 dh
		raspi-gpio set 22 dl

		result=0

		echo "##################"
		echo "Button pressed"
		echo "Starting tests"

		sleep 1

		buttonPressed=$(raspi-gpio get 26 | cut -d '=' -f 2 | cut -d ' ' -f 1)
		if [ "${buttonPressed}" -eq "0" ]; then
			raspi-gpio set 17 dh
			numExpEthDrvOk=1
		else
			numExpEthDrvOk=2
		fi

		echo "Checking ethernet driver messages"
		echo "Expected number of interfaces: ${numExpEthDrvOk}"
		yes "dummy" | head -n 20 >> /dev/kmsg
		rmmod enc28j60 &> /dev/null
		modprobe enc28j60
		numEthDrvOk=$(dmesg | tail -n 10 | grep "${encDrvMsg}" | wc -l)
		if [ "${numEthDrvOk}" -eq "${numExpEthDrvOk}" ]; then
			echo "Ethernet test OK"
		else
			result=1
			echo "######"
			echo "Error: Number of working interfaces: ${numEthDrvOk}"
			echo "######"
		fi

		echo "Comparing EEPROM data to factory file"
		cmp ${testingDir}/${eepFile} ${i2cDir}/${i2cDev}/eeprom -n $(wc -c ${testingDir}/${eepFile} | cut -d " " -f 1)
#		false
		if [ "$?" -ne "0" ]; then
			echo "Data on EEPROM differs from factory file"
			if [ -z "$1" ]; then
				echo "Writing factory file to EEPROM"
				dd if=${testingDir}/${eepFile} of=${i2cDir}/${i2cDev}/eeprom
			fi

			echo "Comparing again"
			cmp ${testingDir}/${eepFile} ${i2cDir}/${i2cDev}/eeprom -n $(wc -c ${testingDir}/${eepFile} | cut -d " " -f 1)
			if [ "$?" -eq "0" ]; then
				echo "EEPROM test OK"
			else
				result=1
				echo "######"
				echo "Error: Data on EEPROM still differs from factory file"
				echo "######"
			fi
		else
			echo "EEPROM test OK"
		fi

		if [ "${result}" -eq "0" ]; then
			showOk
		else
			showFailed
		fi

		elapsedTime=$((${SECONDS} - ${startTime}))
		echo "Duration: $(($elapsedTime / 60)) min $(($elapsedTime % 60)) sec"
		echo "##################"

		echo "Waiting for button pressed event"
	fi

	sleep 1
done

exit 0
