#!/bin/sh
# gpio85为LED灯，gpio79为风扇,下文的max=70000和min=60000分别为风扇的起转温度和停转温度，70000=70摄氏度。监测刷新时间为20秒
max=53000
t1=52000
t2=5150
t3=51000
min=48000
echo $max, $min

echo 79 >/sys/class/gpio/export
echo "out" >/sys/class/gpio/gpio79/direction
echo 79 >/sys/class/gpio/unexport
/opt/fan
sleep 1
killall fan >/dev/null 2>&1
echo 10002 >/sys/class/pwm/pwmchip0/pwm0/duty_cycle
fullpower=1
poweron=1

while true; do
    t=$(/bin/cat /sys/class/thermal/thermal_zone0/temp)
    echo "$t"
    if [ "$t" -lt $min ]; then
        killall fan >/dev/null 2>&1
        echo 79 >/sys/class/gpio/export
        echo "in" >/sys/class/gpio/gpio79/direction
        echo 79 >/sys/class/gpio/unexport
        fullpower=0
        poweron=0
        sleep 7
        continue
    fi

    if [ "$fullpower" -le 0 ]; then

        if [ "$t" -gt $max ]; then
            if [ "$poweron" -le 0 ]; then
                echo 79 >/sys/class/gpio/export
                echo "out" >/sys/class/gpio/gpio79/direction
                echo 79 >/sys/class/gpio/unexport
                /opt/fan
                sleep 1
                killall fan >/dev/null 2>&1
                poweron=1
            fi

            echo 10002 >/sys/class/pwm/pwmchip0/pwm0/duty_cycle
            fullpower=1

        elif [ "$t" -gt $t1 ] && [ "$t" -le $max ]; then
            if [ "$poweron" -le 0 ]; then
                echo 79 >/sys/class/gpio/export
                echo "out" >/sys/class/gpio/gpio79/direction
                echo 79 >/sys/class/gpio/unexport
                /opt/fan
                sleep 1
                killall fan >/dev/null 2>&1
                poweron=1
            fi
            echo 8502 >/sys/class/pwm/pwmchip0/pwm0/duty_cycle
        elif [ "$t" -gt $t2 ] && [ "$t" -le $t1 ]; then
            if [ "$poweron" -le 0 ]; then
                echo 79 >/sys/class/gpio/export
                echo "out" >/sys/class/gpio/gpio79/direction
                echo 79 >/sys/class/gpio/unexport
                /opt/fan
                sleep 1
                killall fan >/dev/null 2>&1
                poweron=1
            fi
            echo 7502 >/sys/class/pwm/pwmchip0/pwm0/duty_cycle
        elif [ "$t" -gt $t3 ] || [ "$t" -le $t2 ]; then
            if [ "$poweron" -le 0 ]; then
                echo 79 >/sys/class/gpio/export
                echo "out" >/sys/class/gpio/gpio79/direction
                echo 79 >/sys/class/gpio/unexport
                /opt/fan
                sleep 1
                killall fan >/dev/null 2>&1
                poweron=1
            fi
            echo 6002 >/sys/class/pwm/pwmchip0/pwm0/duty_cycle
        fi
    fi
    sleep 10
done
