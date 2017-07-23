
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
- Fix slow EEPROM write
  - Try bs=32
  - Try pagesize in dts: http://elixir.free-electrons.com/linux/v4.0/source/Documentation/devicetree/bindings/eeprom.txt
- Implement update
  - Pressing button on startup => update
  - Visualize: Red + Green => update in progress
  - Visualize: Update finished
  - Auto-Reboot => Visualize (No LEDs?)
- Show Internet connection
  - Visu:
    - Yellow + Green on Startup => Internet connection ok
    - Red + Yellow + Green => No Internet
  - Use ping to verify
- Update Visu after Internet state
- Use command: dtoverlay
- Green after boot
