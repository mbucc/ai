#! /bin/sh
# Output log lines that we don't expect to stdout
# Since : Wed Nov 19 18:10:37 UTC 2014
# Author: mkbucc@gmailcom
#
#	Usage example (in crontab):
#		./ai.sh
#

HOST=vps44276563

# HTML mail looks sooo much better on my phone.
OUTFN=/tmp/$(basename $0)-mail.$$.tmp

# So we can put comments in the stop lists
TMP1=/tmp/$(basename $0)-files.$$.tmp
TMP2=/tmp/$(basename $0)-rules.$$.tmp
grep -v '\(^#\|^[:blank:]*$\)' /root/bin/stopfiles > $TMP1
grep -v '\(^#\|^[:blank:]*$\)' /root/bin/stoplist > $TMP2


[ "x$MAILTO" != "x" ] && TO=$MAILTO || TO=$USER

# doctype and xmlns guidance from http://htmlemailboilerplate.com/.

cat > $OUTFN << EOF
To: $TO
Subject: Log Bot yammered on $(date +%F)
Content-Type: text/html

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Log Bot yammered on $(date +%F)</title>
</head>
<body style="margin: 5%; padding: 0; font-family: Courier, monospace">
<p><i>Generated at $(date "+%T %Z")</i></p>
EOF

# Piping into while creates a subshell,
# which can't update variables.
# So use line count change to figure out
# if we need to send email.
N0=$(cat $OUTFN | wc -l)
find /var/log -type f | grep -v -f $TMP1 |  while read fn; do
    if grep -v -f $TMP2 $fn > /dev/null ; then
        echo "<h2>$fn</h2>" >> $OUTFN
        echo "<pre>" >> $OUTFN

	# Add paragraph breaks
	# so if phone wraps log lines
	# we can still distinguish.
	grep -n -v -f $TMP2 $fn |sed 's/$/<p>/' >> $OUTFN

        echo "</pre>" >> $OUTFN
    fi
done
N1=$(cat $OUTFN | wc -l)

cat >> $OUTFN << EOF
</body>
</html>
EOF
if [ $N1 -gt $N0 ] ; then
	sendmail -t < $OUTFN
fi

rm -f $TMP1 $TMP2 $OUTFN
