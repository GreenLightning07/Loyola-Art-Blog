#!/bin/bash

total_found=0

score_report="/home/cyber/Desktop/ScoreReport.html"
tail xxzz.txt
total_found=`cat xxzz.txt`
function update-found
{
	#updates vuln found counts in score report
	
        sed -i "s/id=\"total_found\".*/id=\"total_found\">$total_found\/54<\/center><\/h3>/g" $score_report

	echo $total_found > xxzz.txt
}

function show-vuln()
{
	#allows vuln name to be seen in score report
	sed -i "s/id=\"$1\"style=\"display:none\"/id=\"$1\"style=\"display:block\"/g" $score_report
	((total_found+=$4))
	#replaces placeholder name with actual vuln name (obfuscation)
	sed -i "s/$2/$3/g" $score_report
	notify-send "Congrats!" "You Gained Points"
	update-found
}

function hide-vuln()
{
	#hides vuln name from score report
	sed -i "s/id=\"$1\"style=\"display:block\"/id=\"$1\"style=\"display:none\"/g" $score_report
	((total_found-=$4))
	#replaces placeholder name (people should keep their own notes on the points they've gained)
	sed -i "s/$2/$3/g" $score_report
	notify-send "Uh Oh!" "You Lost Points"
	update-found
}

function penalty()
{
	sed -i "s/id=\"$1\"style=\"display:none\"/id=\"$1\"style=\"display:block\"/g" $score_report
	((total_found-=$4))
        #replaces placeholder name (people should keep their own notes on the points they've gained)
        sed -i "s/$2/$3/g" $score_report
        notify-send "Uh Oh!" "You Lost Points"
        update-found

}

function remove-penalty()
{
	#allows vuln name to be seen in score report
        sed -i "s/id=\"$1\"style=\"display:block\"/id=\"$1\"style=\"display:none\"/g" $score_report
        ((total_found+=$4))
        #replaces placeholder name with actual vuln name (obfuscation)
        sed -i "s/$2/$3/g" $score_report
        notify-send "Congrats!" "You Gained Points"
        update-found

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

update-found

while true
do
	check "! dpkg -l | grep wireshark" "1" "Wireshark is removed +5" "5"
	check "! cat /etc/group | grep sudo | grep -iF nick" "2" "Nick is not an admin +2" "2"
	check "! cat /etc/passwd | grep -iF brian" "3" "Unauthorized user Brian is removed +2" "2"
	check "! cat /etc/passwd | grep -iF dom" "4" "Unauthorized user Dom is removed +2" "2"
	check "cat /etc/group | grep -iF theboys" "5" "Group theboys is added +1" "1"
	check "cat /etc/group | grep -iF theboys | grep -iF anshul | grep -iF casey | grep -iF jack | grep -iF  andrew | grep -iF  brendan" "6" "Anshul, Casey, Jack, and Brendan are added to theboys +1" "1"
	check "cat /etc/passwd | grep -iF morale" "7" "user Morale is added +1" "1"
	check "! cat /etc/apt/sources.list | grep ^\"deb\" | grep -iF us.archive" "8" "Downloading packages from Main Server +3" "3" 
	check "! cat /var/spool/cron/crontabs/root | grep netcat && ! dpkg -l | grep netcat" "9" "Netcat backdoor is removed and netcat is deleted +10" "10"
	check "! cat /etc/sudoers | grep NOPASSWD" "10" "Visudo is correctly configured +5" "5"
	check "! cat /etc/shadow | grep cyber | grep \$1\$" "11" "Secure password set for cyber +5" "5"
	check "cat /etc/ssh/sshd_config | grep ^PermitRootLogin | grep -iF no" "12" "Root login for SSH disabled +2" "2"
	check "cat /etc/ssh/sshd_config | grep ^StrictModes | grep -iF yes" "13" "Strict modes enabled +3" "3"
	check "cat /etc/ssh/sshd_config | grep ^MaxAuthTris | grep 3" "14" "Max authentication tries for SSH lowered to 3 +5" "5"
	check "cat /etc/ssh/sshd_config | grep ^MaxSessions | grep 13" "15" "Max sessions set to appropriate amount +10" "10" 
	check "cat /etc/ssh/sshd_config | grep ^PermitEmptyPasswords | grep -iF no" "16" "Permit empty passwords set to false +3" "3"
	check "cat /etc/ssh/sshd_config | grep ^X11Forwarding | grep -iF no" "17" "Disable X11 Forwarding +5" "5"
	check "cat /etc/login.defs | grep PASS_MAX_DAYS | grep 90 && cat /etc/login.defs | grep PASS_MIN_DAYS | grep 10 && cat /etc/login.defs | grep PASS_WARN_AGE | grep 7" "18" "Login.defs properly configured +6" "6"
	check "cat /etc/pam.d/common-auth | grep -iF deny | grep 5" "19" "Login retries set to 5 +2" "2"
	check "! cat /home/cyber/.mozilla/firefox/f69cat5j.default-release/prefs.js | grep false | grep malware && cat /home/cyber/.mozilla/firefox/f69cat5j.default-release/prefs.js | grep -v ever | grep  https_only_mode" "20" "Firefox properly configured +4" "4"

	sleep 10
done
