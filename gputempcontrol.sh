#!/bin/bash

checkTemp(){	
  echo $(date)
  echo "Max operating temperature is: " $2
  echo "Min operating temperature is: " $3

  counter=0
  while [ $counter -lt $1 ]
  do
    status=$(nvidia-smi -i $counter)
    temp=$(echo $status | grep -o "[0-9]\{2\}C" | cut -c1-2 | xargs)

    currentfs=$(echo $status | grep -o "[0-9]\{2\}%" | cut -c1-2 |head -1 | xargs)
    if [ $currentfs = "00" ]; then 
      currentfs=$(echo $status | grep -o "[0-9]\{3\}%" | cut -c1-3 | head -1 | xargs)
    fi
    cpower=$(echo $status | grep -o "[0-9]\{3\}W" | cut -c1-3 | head -1 | xargs)
    if ! [[ $cpower =~ ^[0-9]+$ ]]; then
      cpower=$(echo $status | grep -o "[0-9]\{2\}W" | cut -c1-2 | head -1)
    fi
    echo "GPU $counter current temp is" $temp ", fan speed is" $currentfs "%, power consumption is" $cpower "W"
    
    if  [ $temp -gt $2 ] && [ $currentfs -lt 100 ];
    then
      echo "GPU $counter temp is too high! Set fan speed to 100"
      setFanspeed $counter 100 >/dev/null
    fi
    if  [ $temp -gt $2 ] && [ $currentfs -eq 100 ];
    then
      echo "GPU $counter fan speed is 100 but temperature is still over max operating temp $2"
      tpower=$(expr $cpower*0.95 | bc)
      echo "Reduce 5% current power, set GPU $counter power limit to $tpower"
      nvidia-smi -i $counter -pl $tpower >/dev/null
    fi
    if [ $temp -lt $3 ];
    then
      targetFanspeed=$(expr $temp - $3 + $currentfs)
      echo "Reduce GPU $counter fan speed to" $targetFanspeed '%'
      setFanspeed $counter $targetFanspeed >/dev/null 
    fi
    ((counter++))
  done
}

setFanspeed(){
  res=$(DISPLAY=:0 XAUTHORITY=/var/run/lightdm/root/:0 nvidia-settings -a "[fan:$1]/GPUTargetFanSpeed=$2")
  echo $res
}

getFanspeed(){
  res=$(nvidia-smi -i $1 | grep -o "[0-9]\{2\}%" | cut -c1-2 | head -1)
  echo $res
}

cnt=$(nvidia-smi -L | wc -l)
echo "Number of Nvidia GPU: " $cnt
#for (( i=0;i<$cnt; i++))
#do
#  setFanspeed $i 100 >/dev/null
#done
#echo "Set all GPU fan speed to 100%"

while  [ 1 -gt 0 ]
do
  checkTemp $cnt $1 $2
  sleep $3
  echo -e "\n"
done
