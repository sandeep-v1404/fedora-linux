#!/bin/sh

main() {
    run
    exit_terminal
}

run() {
    # MONITOR_COUNT="COMMAND OUTPUT"

    MONITOR_COUNT="$(xrandr --listactivemonitors | wc -l)"

    if [ "$MONITOR_COUNT" == 2 ]
    then
	    xrandr --output HDMI-2 --mode 1920x1080 --left-of eDP-1
    else
        xrandr --output HDMI-2 --off
    fi
}

exit_terminal(){
    kill -9 $PPID
}

main
