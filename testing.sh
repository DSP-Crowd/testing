#!/bin/sh

i2cDir="/sys/class/i2c-adapter/i2c-0"
i2cAddDevCmd="24c32 0x50"
i2cDev="0-0050"

echo Testing

raspi-gpio set 26 ip pu

sudo echo "${i2cAddDevCmd}" > ${i2cDir}/new_device

while true; do
	buttonPressed=$(raspi-gpio get 26 | cut -d '=' -f 2 | cut -d ' ' -f 1)

	if [ "${buttonPressed}" -eq "0" ]; then
		echo "Button pressed"
		echo "Starting Tests"

		

		break;
	fi

	sleep 1
done
