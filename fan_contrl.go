package nasstuff

import (
	"os/exec"
	"strconv"
	"time"
)

const (
	max = 53000
	min = 49000
	off = 47000
)

func main() {

	poweronFan()
	setFanSpeed(1000)
	fullPower := true
	poweron := true

	size := max - min

	nowTemp := 0
	temp := 0
	for {
		temp = getTemp()
		if temp < off {
			poweroffFan()
			fullPower = false
			poweron = false
			time.Sleep(10 * time.Second)
			continue
		}

		if !fullPower {
			if temp > max {
				if !poweron {
					poweronFan()
					poweron = true
				}
				setFanSpeed(10000)
				fullPower = true

			} else {
				speed := 0
				if temp > nowTemp {
					speed = countSpped(temp, size)
				} else if nowTemp-temp >= size/5 {
					speed = countSpped(temp, size)
				}
				if !poweron {
					poweronFan()
				}
				setFanSpeed(speed)
				fullPower = false
			}
		}
		time.Sleep(10 * time.Second)
	}
}

func countSpped(temp int, size int) int {

	if temp <= min {
		return 40000
	}

	if temp >= max {
		return 10000
	}

	speed := (temp-min)/size*60000 + 40000
	if speed > 10000 {
		speed = 10000
	}

	return int(speed)
}

func getTemp() int {
	tempCmd := exec.Command("/bin/cat /sys/class/thermal/thermal_zone0/temp")
	tempOut, err := tempCmd.Output()
	if err != nil {
		return max
	}
	temp, err := strconv.Atoi(string(tempOut))
	if err != nil {
		return max
	}

	return temp
}

func setFanSpeed(speed int) {
	// todo
}

func poweroffFan() {
	//todo
}

func poweronFan() {
	fanGpioOnCmd := exec.Command("echo 79 >/sys/class/gpio/export")
	fanGpioOnCmd.Run()

	fandirectionOnCmd := exec.Command("echo \"out\" >/sys/class/gpio/gpio79/direction")
	fandirectionOnCmd.Run()

	fanGpioOffCmd := exec.Command("echo 79 >/sys/class/gpio/unexport")
	fanGpioOffCmd.Run()

	fanBinOnCmd := exec.Command("/opt/fan")
	fanBinOnCmd.Run()

	time.Sleep(1 * time.Second)

	fanBinOffCmd := exec.Command("killall fan >/dev/null 2>&1")
	fanBinOffCmd.Run()

}
