#!/bin/bash

i2cDir="/sys/class/i2c-adapter/i2c-0"
i2cAddDevCmd="24c32 0x50"
i2cDev="0-0050"
eepFile="rr_base.eep"

if [ "$(id -u)" != "0" ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

echo "Initializing tests"

# Initialize LEDs: Red Yellow Green => Low
raspi-gpio set 17 op
raspi-gpio set 27 op
raspi-gpio set 22 op
raspi-gpio set 17 dh
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
sleep 1
raspi-gpio set 17 dl
raspi-gpio set 27 dl
raspi-gpio set 22 dl

echo "Done initializing"
echo "Waiting for button pressed event"

while true; do
	buttonPressed=$(raspi-gpio get 26 | cut -d '=' -f 2 | cut -d ' ' -f 1)

	if [ "${buttonPressed}" -eq "0" ]; then
		startTime=${SECONDS}

		raspi-gpio set 17 dl
		raspi-gpio set 27 dh
		raspi-gpio set 22 dl

		echo "Button pressed"
		echo "Starting Tests"

		#dd if=${eepFile} of=${i2cDir}/${i2cDev}/eeprom
		cmp ${eepFile} ${i2cDir}/${i2cDev}/eeprom -n $(wc -c ${eepFile} | cut -d " " -f 1)

		if [ "$?" -eq "0" ]; then
			raspi-gpio set 17 dl
			raspi-gpio set 27 dl
			raspi-gpio set 22 dh

			echo "Test OK"
		else
			raspi-gpio set 17 dh
			raspi-gpio set 27 dl
			raspi-gpio set 22 dl

			echo "Test FAILED"
		fi

		elapsedTime=$((${SECONDS} - ${startTime}))
		echo "Duration: $(($elapsedTime / 60)) min $(($elapsedTime % 60)) sec"

		echo "Waiting for button pressed event"
	fi

	sleep 1
done

exit 0
