#! /bin/bash

sleep 10
git clone -b misc https://github.com/GreenLightning07/MadagascarLAMP.git
chmod +x MadagascarLAMP/changes.sh
chmod +x MadagascarLAMP/scorebot.sh
mv MadagascarLAMP/scorebot.sh /var/local/scorebot.sh
mv MadagascarLAMP/ScoreReport.html /home/skipper/Desktop/ScoreReport.html
mv MadagascarLAMP/README.html /home/skipper/Desktop/README.html
mv MadagascarLAMP/Contact.html /home/skipper/Desktop/Contact.html
MadagascarLAMP/changes.sh
sudo /var/local/scorebot.sh
