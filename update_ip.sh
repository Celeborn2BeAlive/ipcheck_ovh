#/bin/sh
 
#
# CONFIG GOES HERE
#

PATH_APP=$(dirname "$0")
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
    echo "No IP retrieved"
else
    if [ "$OLD_IP" != "$IP" ]; then
        echo "Current IP: $IP - Old IP: $OLD_IP - IP Changed - Update DynHost"
        RESULT=`$PATH_IPCHECK -a $IP $LOGIN $PASSWORD $HOST`
        TMP=`echo $RESULT | grep 'successful'`
        if [ -z "$RESULT" ] || [ "$TMP" ]; then
            echo "Success - $IP"
            echo "$IP" > $PATH_FILE_OLD_IP
        else
            echo "Error: $RESULT"
        fi
    else
        echo "Current IP: $IP - Old IP: $OLD_IP - No IP Change"
    fi
fi
