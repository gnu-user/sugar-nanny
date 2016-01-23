#/bin/bash

LOGFILE=node_mem

while true
do
	for p in $(pidof node)
	do
		echo "$(date '+%Y.%m.%d-%H:%M.%S'),$(ps h -o rss ${p} | awk '{ foo = $1 / 1024 / 1024 ; print foo "MB" }')" >> ${LOGFILE}.${p}
		echo "$(date '+%Y.%m.%d-%H:%M.%S') $(ps h -o rss ${p} | awk '{ foo = $1 / 1024 / 1024 ; print foo "MB" }')" 
	done
	sleep 1
done
