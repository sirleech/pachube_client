An Arduino Ethernet datalogger sending a feed to Pachube.com. The internal watchdog timer is used along with a hard reset to the Ethernet Shield from digital pin 9. Original code is forked from the article:
http://community.pachube.com/arduino/ethernet/watchdog

Hardware note: 
--------------

Arduino Uno (with Optiboot bootloader)
Arduino Ethernet Shield or Freetronics Ethernet Shield (Wiznet 5100)

Software note:
--------------

- Arduino IDE 0021

Required Libraries:
- EthernetDHCP.h Library 1.0b4
  -- http://gkaindl.com/software/arduino-ethernet/dhcp/
  -- or https://github.com/sirleech/ArduinoEthernetDHCP_1.0b4
  

Libraries note: 
--------------
Special thanks to:
Jordan Terrell(http://blog.jordanterrell.com/) and Georg Kaindl(http://gkaindl.com) for DHCP library
Tinker.it http://code.google.com/p/tinkerit/wiki/TrueRandom
