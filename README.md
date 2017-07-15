
PREPARATION:

- Copy file dspc-base.dtbo into directory /boot/overlays/
- Add following lines to /boot/config.txt
  dtparam=i2c_vc=on
  dtoverlay=dspc-base
- Add following line to /etc/rc.local:
  /home/pi/testing/testing.sh &
  For testing use following line:
  /home/pi/testing/testing.sh &> /home/pi/testing/log.txt &
- Reboot
