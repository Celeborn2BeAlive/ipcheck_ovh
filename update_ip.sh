#/bin/sh
 
#
# CONFIG GOES HERE
#

PATH_APP=$(dirname "$0")
PATH_LOG=./log
PATH_IPCHECK=./ipcheck.py
PATH_FILE_OLD_IP=./old_ip

#
# CONFIG END
#

cd $PATH_APP

# credentials.sh must define the following variables
source ./credentials.sh

#prevent error when ipcheck.err exists
rm -f ./ipcheck.err

IP=`curl http://checkip.dyndns.org | sed -nre 's/^.* (([0-9]{1,3}\.){3}[0-9]{1,3}).*$/\1/p'`

if [ -f "$PATH_FILE_OLD_IP" ]
then
    OLD_IP=`cat $PATH_FILE_OLD_IP`
else
    OLD_IP=""
fi

if [ -z "$IP" ]; then
    printf "$(date) - No IP retrieved\n" >> $PATH_LOG
else
    if [ "$OLD_IP" != "$IP" ]; then
        printf "$(date) - Current IP: $IP - Old IP: $OLD_IP - IP Changed - Update DynHost\n" >> $PATH_LOG
        RESULT=`$PATH_IPCHECK -a $IP $LOGIN $PASSWORD $HOST`
        TMP=`echo $RESULT | grep 'successful'`
        if [ -z "$RESULT" ] || [ "$TMP" ]; then
            printf "$(date) - Success\n" >> $PATH_LOG
            printf "$IP" > $PATH_FILE_OLD_IP
        else
            printf "$(date) - Error: $RESULT\n" >> $PATH_LOG
        fi
        printf "\n" >> $PATH_LOG
    else
        printf "$(date) - Current IP: $IP - Old IP: $OLD_IP - No IP Change\n" >> $PATH_LOG
    fi
fi
