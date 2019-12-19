# KEY VARIABLE RECALL & EXECUTION
source /var/plexguide/pgscan/endbanner.sh

mkdir -p /var/plexguide/pgscan
touch /var/plexguide/pgscan/plex.token
touch /var/plexguide/pgscan/plex.pw
touch /var/plexguide/pgscan/plex.user
# FUNCTIONS START ##############################################################
# FIRST FUNCTION
variable() {
  file="$1"
  if [ ! -e "$file" ]; then echo "$2" >$1; fi
}

passtartfirst() {
file="/opt/plex_autoscan/config/config.json"
  if [[ ! -f $file ]]; then
	pasundeployed 
  else plexcheck; fi
}

deploycheck() {
  dcheck=$(systemctl is-active plex_autoscan.service)
  if [ "$dcheck" == "active" ]; then
    dstatus="✅ DEPLOYED"
  else dstatus="⚠️ NOT DEPLOYED"; fi
}
userstatus() {
  userdep=$(cat /var/plexguide/pgscan/plex.pw)
  if [ "$userdep" != "" ]; then
    ustatus="✅ DEPLOYED"
  else ustatus="⚠️ NOT DEPLOYED"; fi
}

tokenstatus() {
  ptokendep=$(cat /var/plexguide/pgscan/plex.token)
  if [ "$ptokendep" != "" ]; then
        if [[ ! -f "/opt/plex_autoscan/config/config.json" ]]; then
                pstatus="❌ DEPLOYED BUT PAS CONFIG MISSING";
        else
                PGSELFTEST=$(curl -LI "http://$(hostname -I | awk '{print $1}'):32400/system?X-Plex-Token=$(cat /opt/plex_autoscan/config/config.json | jq .PLEX_TOKEN | sed 's/"//g')" -o /dev/null -w '%{http_code}\n' -s)
                if [[ $PGSELFTEST -ge 200 && $PGSELFTEST -le 299 ]]; then  pstatus="✅ DEPLOYED"
                else pstatus="❌ DEPLOYED BUT PAS TOKEN FAILED"; fi
        fi
  else pstatus="⚠️ NOT DEPLOYED"; fi
}

plexdockeruser() {
plexdocker=$(cat /var/plexguide/image/plex)
if [[ $plexdocker == "linuxserver/plex:latest" ]]; then
 echo -e "abc" >/var/plexguide/pgscan/plex.docker
 else echo "plex" >/var/plexguide/pgscan/plex.docker; fi
}

plexcheck() {
  pcheck=$(docker ps --format {{.Names}} | grep "plex")
  if [ "$pcheck" == "" ]; then
	printf '
	━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	⛔️  WARNING! - Plex is Not Installed or Running! Exiting!
	━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	'
    dontwork
  fi
}

user() {
  touch /var/plexguide/pgscan/plex.pw
  user=$(cat /var/plexguide/pgscan/plex.pw)
  if [ "$user" == "" ]; then
    bash /opt/plexguide/menu/pgscan/scripts/plex_pw.sh
  fi
}
token() {
  touch /var/plexguide/pgscan/plex.token
  ptoken=$(cat /var/plexguide/pgscan/plex.token)
  if [ "$ptoken" == "" ]; then
    bash /opt/plexguide/menu/pgscan/scripts/plex_token.sh 1>/dev/null 2>&1
	sleep 2
    ptoken=$(cat /var/plexguide/pgscan/plex.token)
    if [ "$ptoken" == "" ]; then
	printf '
	━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	⛔️  WARNING!  Failed to Generate a Valid Plex Token! 
	⛔️  WARNING!  Exiting Deployment!
	━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	'
	dontwork
    fi
  fi
}
# BAD INPUT
badinput() {
  echo
  read -p '⛔️ ERROR - BAD INPUT! | PRESS [ENTER] ' typed </dev/tty
  question1
}

dontwork() {
 echo
  read -p 'Confirm Info | PRESS [ENTER] ' typed </dev/tty
  exit 0
}

works(){
 echo
  read -p 'Confirm Info | PRESS [ENTER] ' typed </dev/tty
  question1
}
credits(){
clear
chk=$(figlet Plex Auto Scan | lolcat )
  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Plex_AutoScan Credits 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$chk

#########################################################################
# Author:   l3uddz                                                      #
# URL:      https://github.com/l3uddz/plex_autoscan                     #
# Coder of plex_autoscan                                                #
# --                                                                    #
# Author(s):     l3uddz, desimaniac                                     #
# URL:           https://github.com/cloudbox/cloudbox                   #
# Coder of plex_autoscan role                                           #
# --                                                                    #
#         Part of the Cloudbox project: https://cloudbox.works          #
#########################################################################
#                   GNU General Public License v3.0                     #
#########################################################################
EOF

 echo
  read -p 'Confirm Info | PRESS [ENTER] ' typed </dev/tty
  question1
}

doneenter(){
 echo
  read -p 'All done | PRESS [ENTER] ' typed </dev/tty
  question1
}

showupdomain() {
clear
PAS_CONFIG="/opt/plex_autoscan/config/config.json"

SERVER_IP=$(ip a | grep glo | awk '{print $2}' | head -1 | cut -f1 -d/)
SERVER_PORT=$(cat ${PAS_CONFIG} | jq -r .SERVER_PORT)
SERVER_PASS=$(cat ${PAS_CONFIG} | jq -r .SERVER_PASS)

  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Plex_AutoScan Domain Interface
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

"Your Plex Autoscan URL:"

"http://${SERVER_IP}:${SERVER_PORT}/${SERVER_PASS}"

Press Enter to Exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
 works
}
remove(){
ansible-playbook /opt/plexguide/menu/pgscan/remove-pgscan.yml 
  printf '
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Plex_AutoScan is full removed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
'
 echo 
  read -p 'All done | PRESS [ENTER] ' typed </dev/tty
}
# FIRST QUESTION
question1() {
userstatus
tokenstatus
deploycheck
  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Plex_AutoScan Interface  || l3uddz/plex_autoscan
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NOTE : Plex_AutoScan are located in /opt/plex_autoscan

[1] Deploy Plex Username & Plex Password  [ $ustatus ]
[2] Deploy Plex Token                     [ $pstatus ]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[A] Deploy Plex-Auto-Scan                 [ $dstatus ]

[D] PlexAutoScan Domain
[S] Show last 50 lines of Plex_AutoScan log
[R] Remove Plex_AutoScan
[C] Credits

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Z] - Exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

  read -p '↘️  Type Number | Press [ENTER]: ' typed </dev/tty

  case $typed in
  1) bash /opt/plexguide/menu/pgscan/scripts/plex_pw.sh && clear && question1 ;;
  2) bash /opt/plexguide/menu/pgscan/scripts/plex_token.sh && clear && question1 ;;
  A) ansible-playbook /opt/plexguide/menu/pg.yml --tags plex_autoscan && clear && pasdeployed && question1 ;;
  a) ansible-playbook /opt/plexguide/menu/pg.yml --tags plex_autoscan && clear && pasdeployed && question1 ;;
  D) showupdomain && clear && question1 ;;
  d) showupdomain && clear && question1 ;;
  S) tail -n 50 /opt/plex_autoscan/plex_autoscan.log && doneenter ;;
  s) tail -n 50 /opt/plex_autoscan/plex_autoscan.log && doneenter;;
  r) remove && doneenter  && sleep 5 && clear && exit 0 ;;
  R) remove && doneenter && sleep 5 && clear && exit 0 ;;
  C) credits && clear && question1 ;;
  c) credits && clear && question1 ;;
  z) exit 0 ;;
  Z) exit 0 ;;
  *) question1 ;;
  esac
}
# FUNCTIONS END ##############################################################
passtartfirst
plexdockeruser
userstatus
tokenstatus
deploycheck
question1
