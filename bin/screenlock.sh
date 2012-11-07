#!/bin/bash
DISPLAY=:0.0

SBIN='/usr/bin/gnome-screensaver-command'

lock() {
	sudo -u $1 $SBIN -l
}

unlock() {
	sudo -u $1 $SBIN -d
}

ssactive() {
	status=`sudo -u $1 $SBIN -q`

	if [ "$status" == "The screensaver is inactive" ]; then
		return 0;
	else
		return 1;
	fi
}

ssactive $1
active=$?

if [ $2 == 'lock' ] && [ $active -eq 0 ]; then
	lock $1
elif [ $2 == 'unlock' ] && [ $active -eq 1 ]; then
	unlock $1
fi
