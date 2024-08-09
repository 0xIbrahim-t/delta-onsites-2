#!/bin/bash


nohup ./daemon.sh & disown

echo "$!" > pid.txt
