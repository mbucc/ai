#! /bin/sh -e
# Output unique log lines and their count to stdout.
# Since : Wed Nov 19 17:48:36 UTC 2014
# Author: mkbucc@gmailcom
#
#	Usage examples:
#		./setup.ai.sh | less
#		./setup.ai.sh | wc -l
#		./setup.ai.sh >> stoplist ; vi stoplist
#


HOST=vps44276563

# So we can put comments in the stop lists
TMP1=/tmp/$(basename $0)-files.$$.tmp
TMP2=/tmp/$(basename $0)-rules.$$.tmp
grep -v '\(^#\|^[:blank:]*$\)' stopfiles > $TMP1
grep -v '\(^#\|^[:blank:]*$\)' stoplist > $TMP2

find /var/log -type f | grep -v -f $TMP1 | \
    xargs cat | \
        tr   -dc  '[:print:]\n'     |  \
        sed  -e   "s/^.*${HOST}//"    |  \
        sed  -e   's/\[[0-9]*\]//'  |  \
    grep -v -f $TMP2 | \
    sort | uniq -c | sort -r -n

rm -f $TMP1
rm -f $TMP2
