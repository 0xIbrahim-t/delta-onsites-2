#!/bin/bash

while true; do
        rm -R *-temp.txt

        while read line; do

                if [[ "$line" == "bridge" ]]; then
                        continue
                fi
                container="$(echo $line | awk '{print $1}')"
                network="$(echo $line | awk '{print $2}')"

                if ! [[ -f $network-temp.txt ]]; then
                        touch $network-temp.txt
                        echo "$container" > $network-temp.txt

                else
                        echo "$container" >> $network-temp.txt
                fi

        done < <(docker ps --format "{{.Names}} {{.Networks}} {{.ID}}")

        while read network_line; do
                network="${network_line:0:-9}"
                y=$(wc -l < $network_line)
                x=0
                while read container; do
                        status=$(docker ps -a --filter "name=$container" --format "{{.Status}}" | awk '{print $3}')
                        status="${status//[$'\t\r\n ']}"

                        if ! [[ "$status" == "seconds" ]];then
                                x=$(($x + 1))
                        fi
                done < $network_line

                if [[ $y == $x ]]; then
                        while read container; do
                                docker stop $container
                                docker logs $container > $container.logs
                        done < $network_line
                fi

        done < <(ls -A *-temp.txt)
        sleep 10
done
