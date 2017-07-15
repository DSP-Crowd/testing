#!/bin/bash

i2cDir="/sys/class/i2c-adapter/i2c-0"
i2cAddDevCmd="24c32 0x50"
i2cDev="0-0050"
eepFile="rr_base.eep"

echo Testing

raspi-gpio set 26 ip pu

sudo echo "${i2cAddDevCmd}" > ${i2cDir}/new_device

while true; do
	buttonPressed=$(raspi-gpio get 26 | cut -d '=' -f 2 | cut -d ' ' -f 1)

	if [ "${buttonPressed}" -eq "0" ]; then
		startTime=${SECONDS}

		echo "Button pressed"
		echo "Starting Tests"

		#sudo dd if=${eepFile} of=${i2cDir}/${i2cDev}/eeprom
		sudo cmp ${eepFile} ${i2cDir}/${i2cDev}/eeprom -n $(wc -c ${eepFile} | cut -d " " -f 1)

		if [ "$?" -eq "0" ]; then
			echo "Test OK"
		else
			echo "Test FAILED"
		fi

		elapsedTime=$((${SECONDS} - ${startTime}))
		echo "Duration: $(($elapsedTime / 60)) min $(($elapsedTime % 60)) sec"

		break;
	fi

	sleep 1
done
