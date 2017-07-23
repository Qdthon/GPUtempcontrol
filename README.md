#Nvidia GPU Temperature & Fan-Speed Auto Control

##Description
This script is used to automatically monitor Nvidia GeForce 10 Series graphics card(GPU) operating temperature. The main goals are:
- Monitor and record GPUs operating status
- Optimize fan speed to keep GPU temperature in preset ranges and reduce fan noise 
- Prevent GPU from overheat by reducing power consumption 

##Prerequisites
- Ubuntu 16.04
- GeForce 10 Series graphics card
- Nvidia Linux X64 display driver 375.66 or later

##To Run
Set operating temperature between 70C and 80C, check temperature and make necessary fan speed adjustments every 10 minutes. 
```
sh gputempcontrol.sh 80 70 10m
```
Set operating temperature at 75C, check temperature and mek necessary fan speed adjustments every 30 minutes.
```
sh gputempcontrol.sh 75 30m
```
The GPU temperature goes down slowly after the fan speed is increased. So recheck the temperature at least 10 minutes later. Otherwise the GPU performance will be degraded.
 

