
PREPARATION:

- Copy file dspc-base.dtbo into directory /boot/overlays/
- Add following lines to /boot/config.txt
  dtparam=i2c_vc=on
  dtoverlay=dspc-base
- Add following line to /etc/rc.local:
  /home/pi/testing/testing.sh &
  For testing use following line (bug: not working?):
  /home/pi/testing/testing.sh &> /home/pi/testing/log.txt &
- $ sudo apt-get install raspi-gpio
- Reboot
- Check log with tail -f log.txt

TODO:
- Use command: dtoverlay
