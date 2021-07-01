#!/bin/bash
DATE=$(date)
systemctl status SERVICE.service | grep -i "active (running)"
        if [ "$?" = "0" ]; then
                echo "$DATE ---- Node is UP" >> SERVICE-restart.log

        else
                echo "$DATE ---- Node is DOWN, attempting restart" >> SERVICE-restart.log
                systemctl restart SERVICE.service &>> SERVICE-restart.log

                systemctl status SERVICE.service | grep -i "active (running)"
                if [ "$?" = "0" ]; then
                        echo "$DATE ---- Restart successful" >> SERVICE-restart.log
                else
                        echo "$DATE ---- Restart unsuccessful, trying start"
                        systemctl start SERVICE.service &>> SERVICE-restart.log

                        systemctl status SERVICE.service | grep -i "active (running)"
                        if [ "$?" = "0" ]; then
                                echo "$DATE ---- Node is back up"
                                exit
                        else
                                echo "$DATE -!-!- Self-heal has failed - Please investigate immediately -!-!-"
                        fi

                fi


        fi



