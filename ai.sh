#! /bin/sh
# Output log lines that we don't expect to stdout
# Since : Wed Nov 19 18:10:37 UTC 2014
# Author: mkbucc@gmailcom
#
#	Usage example (in crontab):
#		./ai.sh 1>&2
#

HOST=vps44276563

# So we can put comments in the stop lists
TMP1=/tmp/$(basename $0)-files.$$.tmp
TMP2=/tmp/$(basename $0)-rules.$$.tmp
grep -v '\(^#\|^[:blank:]*$\)' /root/bin/stopfiles > $TMP1
grep -v '\(^#\|^[:blank:]*$\)' /root/bin/stoplist > $TMP2

find /var/log -type f | grep -v -f $TMP1 | while read fn; do
    if grep -v -f $TMP2 $fn > /dev/null ; then
        echo ""
        echo "---------------------------------------------"
        echo $fn
        echo "---------------------------------------------"
    	grep -n -v -f $TMP2 $fn
    fi
done

rm -f $TMP1
rm -f $TMP2
