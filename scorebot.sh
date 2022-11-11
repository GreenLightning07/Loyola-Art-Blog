#!/bin/bash

total_found=0
total_percent=""
total_pen=0

pam_configed=false
encrypt_set=false

score_report="/home/skipper/Desktop/ScoreReport.html"

function update-found
{
	#updates vuln found counts in score report
	total_percent=$(awk -vn=$total_found 'BEGIN{print(n*2.00)}')
	echo $total_percent
        sed -i "s/id=\"total_found\".*/id=\"total_found\">$total_found\/50<\/h3>/g" $score_report
        sed -i "s/id=\"total_percent\".*/id=\"total_percent\">$total_percent%<\/h3>/g" $score_report
	
	echo $total_pen
	
	if ( $total_pen == 0 ); then
		sed -i "s/id=\"p0\"style=\"display:none\"/id=\"p0\"style=\"display:block\"/g" $score_report
	else
		sed -i "s/id=\"p0\"style=\"display:block\"/id=\"p0\"style=\"display:none\"/g" $score_report
	fi
}

function show-vuln()
{
	#allows vuln name to be seen in score report
	sed -i "s/id=\"$1\"style=\"display:none\"/id=\"$1\"style=\"display:block\"/g" $score_report
	((total_found+=$4))
	#replaces placeholder name with actual vuln name (obfuscation)
	sed -i "s/$2/$3/g" $score_report
	notify-send "Congrats!" "You Gained Points"
}

function hide-vuln()
{
	#hides vuln name from score report
	sed -i "s/id=\"$1\"style=\"display:block\"/id=\"$1\"style=\"display:none\"/g" $score_report
	((total_found-=$4))
	#replaces placeholder name (people should keep their own notes on the points they've gained)
	sed -i "s/$2/$3/g" $score_report
	notify-send "Uh Oh!" "You Lost Points"
}

function penalty()
{
	sed -i "s/id=\"$1\"style=\"display:none\"/id=\"$1\"style=\"display:block\"/g" $score_report
	((total_found-=$4))
	((total_pen+=1))
		
        #replaces placeholder name (people should keep their own notes on the points they've gained)
        sed -i "s/$2/$3/g" $score_report
        notify-send "Uh Oh!" "You Lost Points"
}

function remove-penalty()
{
	#allows vuln name to be seen in score report
        sed -i "s/id=\"$1\"style=\"display:block\"/id=\"$1\"style=\"display:none\"/g" $score_report
        ((total_found+=$4))
	((total_pen-1))
	
        #replaces placeholder name with actual vuln name (obfuscation)
        sed -i "s/$2/$3/g" $score_report
        notify-send "Congrats!" "You Gained Points"
}

function notify-send()
{
    #Detect the name of the display in use
    local display=":$(ls /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)"

    #Detect the user using such display
    local user=$(who | grep '('$display')' | awk '{print $1}' | head -n 1)

    #Detect the id of the user
    local uid=$(id -u $user)

    sudo -u $user DISPLAY=$display DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus notify-send "$@"
}

function check()
{
	if ( eval $1 ); then
		if ( cat $score_report | grep "id=\"$2\"" | grep "display:none" ); then
			show-vuln "$2" "Vuln$2;" "$3" "$4"
		fi
	elif ( cat $score_report | grep "id=\"$2\"" | grep "display:block" ); then
		hide-vuln "$2" "$3" "Vuln$2;" "$4"
	fi
}

function check-pen()
{
	if ( eval $1 ); then
		if ( cat $score_report | grep "id=\"$2\"" | grep "display:none" ); then
			penalty "$2" "$2;" "$3" "$4"
		fi
	elif ( cat $score_report | grep "id=\"$2\"" | grep "display:block" ); then
		remove-penalty "$2" "$3" "$2;" "$4"
	fi
}

update-found

while true
do
	update-found
	
	#Forensics
	check 'cat /home/skipper/Desktop/Forensics1 | grep "i like to move it move it"' '1' 'Forensics 1 Correct +5' '5'
	check 'cat /home/skipper/Desktop/Forensics2 | grep "youareanidiot.py"' '2' 'Forensics 2 Correct +5' '5'
	check 'cat /home/skipper/Desktop/Forensics3 | grep "a6155be26441bfcec1fd786651a38f3d"' '3' 'Forensics 3 Correct +5' '5'
	
	#Vulns
	
	#wait 10 seconds
	sleep 10
done
