#!/bin/bash
#Diagnostic test file to assist information gathering for Anonymizer network troubleshooting.
#By: Gabriel
#Date 02/15/2016
#Revision 2
#
clear

#Set window size - TBD
#Assign Colors as variables
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"

#Assign file for diagnostic output
OUTPUTFILE () {
/Users/$USER/Desktop/AU_Diag.txt
}

#Assign Logo as variable
LOGO () {
    echo -e "$COL_BLUE"
    echo '       _/_/                                                            _/                               '
    echo '     _/    _/  _/_/_/      _/_/    _/_/_/    _/    _/  _/_/_/  _/_/        _/_/_/_/    _/_/    _/  _/_/ '
    echo '    _/_/_/_/  _/    _/  _/    _/  _/    _/  _/    _/  _/    _/    _/  _/      _/    _/_/_/_/  _/_/      '
    echo '   _/    _/  _/    _/  _/    _/  _/    _/  _/    _/  _/    _/    _/  _/    _/      _/        _/         '
    echo '  _/    _/  _/    _/    _/_/    _/    _/    _/_/_/  _/    _/    _/  _/  _/_/_/_/    _/_/_/  _/          '
    echo '                                              _/                                                        '
    echo '                                          _/_/                                                          '
    echo -e $COL_RESET
}

#Assign spacer as variable
SPACER () {
echo >> /Users/$USER/Desktop/AU_Diag.txt; echo '/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\_/~\    ' >> /Users/$USER/Desktop/AU_Diag.txt; echo >> /Users/$USER/Desktop/AU_Diag.txt
}

#Display logo
LOGO; SPACER

#Check to see if Anonymizer is installed
#Is iTerm installed
   if [ -d "/Applications/Anonymizer Universal.app" ]
     then
       echo -e "$COL_GREEN"
       echo "Anonymizer Universal is insalled"
       echo -e $COL_RESET
     else
       echo -e "$COL_RED"
       echo "Anonymizer Universal is not installed"
       echo -e "COL_RESET"
   fi

#Checking to see if user is connected to Anonymizer
#curl http://greenlight.anonymizer.com/vpnstatus | sed 's/<[^>]*>/ /g' | tee -a /Users/$USER/Desktop/AU_Diag.txt
echo
    if curl -s http://greenlight.anonymizer.com/vpn_status | grep -q  '"internal":"false"'; then
    echo -e "GREAT, you are not connected to Anonymizer, lets start Begin the Diagnostic test"
        else
                    echo -e "You are currently connected to Anonymizer Universal"; echo; echo
            read -p "Please disconnect from Anonymizer Universal, then Press the  [Enter] key to start the Diagnostic test...or ctrl+c to exit"
                clear
                exec bash "$0"
    fi
echo; echo -e "\033[33;5mStarting Diagnostic\033[0m" | tee -a /Users/$USER/Desktop/AU_Diag.txt; echo

#Date local / UTC
    date | tee -a /Users/$USER/Desktop/AU_Diag.txt && date -u | tee -a /Users/$USER/Desktop/AU_Diag.txt; echo

#Pinging google DNS
    echo Pinging google DNS | tee -a /Users/$USER/Desktop/AU_Diag.txt
    ping -A -c 5 8.8.8.8 | tee -a /Users/$USER/Desktop/AU_Diag.txt
        #Clearing screen and adding logo for next test

#Clear & post logo
clear; LOGO; SPACER

#Running Traceroute to Google DNS
    echo "running traceroute to Google DNS" | tee -a /Users/$USER/Desktop/AU_Diag.txt
    traceroute -w 1 8.8.8.8 | tee -a /Users/$USER/Desktop/AU_Diag.txt; echo

#Clear & post logo
clear; LOGO; SPACER

#Running Traceroute to Anonymizer DNS off to speed up process
    echo "running traceroute to Anonymizer" | tee -a /Users/$USER/Desktop/AU_Diag.txt
    traceroute -n -w 1 -m 10 147.203.108.50 | tee -a /Users/$USER/Desktop/AU_Diag.txt

#Clear & post logo
clear; LOGO; SPACER

#Verifiying DNS works
    echo checking DNS | tee -a /Users/$USER/Desktop/AU_Diag.txt
    nslookup anonymizer.com | tee -a /Users/$USER/Desktop/AU_Diag.txt

#Gathering current tasks to review for pottential conflicts
        echo "gathered running processes" | tee -a /Users/$USER/Desktop/AU_Diag.txt
        ps -cax >> /Users/$USER/Desktop/AU_Diag.txt
        echo

#Running speedtest
    echo running speedtest | tee -a /Users/$USER/Desktop/AU_Diag.txt
    wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test10.zip | tee -a /Users/$USER/Desktop/AU_Diag.txt; echo

#Gathering current tasks to review for pottential conflicts
    echo "gathered running processes" | tee -a /Users/$USER/Desktop/AU_Diag.txt
    ps -cax >> /Users/$USER/Desktop/AU_Diag.txt
    echo

#################################################################################################################################
#Preparing second round of tests
#################################################################################################################################

#Clear & post logo
clear; LOGO; SPACER

#################################
# TESTING ANONYMIZER CONNECTION #
#################################
read -p "Connect to Anonymizer Universal, then Press the [Enter] key to continue with the diagnostic test..."
echo; echo "Prompting user to connect to Anonymizer" >> /Users/$USER/Desktop/AU_Diag.txt

#Checking to see if user is connected to Anonymizer
#curl http://greenlight.anonymizer.com/vpnstatus | sed 's/<[^>]*>/ /g' | tee -a /Users/$USER/Desktop/AU_Diag.txt
#echo
        if curl -s http://greenlight.anonymizer.com/vpn_status | grep -q  '"internal":"true"'; then
                echo -e "You are connected to Anonymizer Univeresal, continuing Diagnostic test"
        else
                echo -e $COL_RED; echo -e "You are not connected to Anonymizer Universal"; echo -e $COL_RESET
                    echo
                    echo
                read -p "Please connect to Anonymizer Universal, then Press the  [Enter] key to continue the Diagnostic test... or ctrl+c to exit"
            if curl -s curl http://greenlight.anonymizer.com/vpn_status | grep -q  '"internal":"true"'; then
                echo -e "You are connected to Anonymizer Univeresal, continuing Diagnostic test"
            else
                echo -e $COL_RED; echo -e "You are still NOT connected to Anonymizer Universal"; echo -e $COL_RESET
                echo "Either Anonymizer or the user failed to establish a connection" >> /Users/$USER/Desktop/AU_Diag.txt
                    echo "gathered Logs" #Gathered Anonymizer Universal Logs
                    cat /private/var/log/system.log >> /Users/$USER/Desktop/AU_Diag.txt; echo; echo; echo; echo
                read -p "Exiting script"; exit
            fi
    fi
echo
SPACER; SPACER; SPACER

#Clear & post logo
clear; LOGO; SPACER

#Date local / UTC
date >> /Users/$USER/Desktop/AU_Diag.txt
date -u >> /Users/$USER/Desktop/AU_Diag.txt

#Pinging google DNS
echo "Pinging google DNS" | tee -a /Users/$USER/Desktop/AU_Diag.txt
        ping -c 5 8.8.8.8 | tee -a /Users/$USER/Desktop/AU_Diag.txt

#Clear & post logo
clear; LOGO; SPACER

#Running Traceroute to Google DNS
    echo "running traceroute to Google DNS" | tee -a /Users/$USER/Desktop/AU_Diag.txt
        traceroute -w 1 -m 15 8.8.8.8 | tee -a /Users/$USER/Desktop/AU_Diag.txt

#Clear & post logo
clear; LOGO; SPACER

#Verifiying DNS works
    echo "checking DNS" | tee -a /Users/$USER/Desktop/AU_Diag.txt
    nslookup anonymizer.com | tee -a /Users/$USER/Desktop/AU_Diag.txt

#Running speedtest
    echo "running speedtest" | tee -a /Users/$USER/Desktop/AU_Diag.txt
    wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test10.zip | tee -a /Users/$USER/Desktop/AU_Diag.txt

#Clear & post logo
clear; LOGO; SPACER

#Gathering Running processes to review for conflicts
    echo "gathered processes"
    ps -ax >> /Users/$USER/Desktop/AU_Diag.txt

#Pull Anonymizer Universal Logs
    echo "gathered Logs"
    tail -n 15 /private/var/log/system.log | grep Anonymizer
    cat /private/var/log/system.log >> /Users/$USER/Desktop/AU_Diag.txt; echo; echo; echo; echo

#Diagnostic complete prompt user to close
read -p "Diagnostic complete AU_Diag.txt is on your desktop. Press the  [Enter] key to close terminal..."
#Want to add troubleshooting steps like manually setting the users DNS, using apple script to launch AU from command line
#Checks to determine if AU is still in the process of connecting before exiting
