#!/bin/bash

core0_temp=$(sensors | grep 'Core 0:' | awk '{print $3}' | tr -d '+°C')
core2_temp=$(sensors | grep 'Core 2:' | awk '{print $3}' | tr -d '+°C')

average_temp=$(echo "($core0_temp + $core2_temp) / 2" | bc)

echo " $average_temp°C"
