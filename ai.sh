#! /bin/sh
# Output log lines that we don't expect to stdout
# Since : Wed Nov 19 18:10:37 UTC 2014
# Author: mkbucc@gmailcom
#
#	Usage example (in crontab):
#		./ai.sh
#

HOST=vps44276563
LOGDIR=/var/log
RETAIL_DATA=$HOME/offsets
RETAIL=/usr/local/bin/retail

mkdir -p ${RETAIL_DATA}

#
# LOGNAME is more universal than USERNAME.
#
[ "x$MAILTO" != "x" ] && TO=$MAILTO || TO=$LOGNAME

#
# Securely create a temp directory or abort with email.
# http://www.linuxsecurity.com/content/view/115462/151/
#
TMPD=$(/bin/mktemp -d "${TMPDIR-/tmp}/ai.XXXXXXXXXX")
if [ $? != 0 ] ; then
    TMPD=${TMPDIR-/tmp}/ai.$RANDOM.$RANDOM.$RANDOM.$$
    ERR=$(umask 077; mkdir "$TMPD" 2>&1)
    if [ $? != 0 ] ; then
        /usr/sbin/sendmail -t <<EOF
To: $TO
Subject: logbot failed to create temporary directory!

Can not create temporary directory: $TMPD
mkdir: $ERR
Command: $0
$(date)
EOF
        exit 1
    fi
fi

#
# Remove comments from stop files.
#
TMP1="$TMPD"/$(basename $0)-files.$$.tmp
TMP2="$TMPD"/$(basename $0)-rules.$$.tmp
grep -v '\(^#\|^[:blank:]*$\)' $HOME/bin/stopfiles > $TMP1
grep -v '\(^#\|^[:blank:]*$\)' $HOME/bin/stoplist > $TMP2

#
# Write out HTML email.
#
# Whether or not we actually send an eamil
# depends on if we get any hits when grepping logs.
#
# doctype and xmlns guidance from http://htmlemailboilerplate.com/.
#
OUTFN="$TMPD"/$(basename $0)-mail.$$.tmp

cat > $OUTFN << EOF
To: $TO
Subject: logbot didn't ignore something
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
TMPFN="$TMPD"/ai.tmp
find $LOGDIR -type f -group adm | grep -v -f $TMP1 | while read fn; do
    $RETAIL -o ${RETAIL_DATA}/ $fn > $TMPFN
    if grep -v -f $TMP2 $TMPFN > /dev/null ; then
        echo "<h2>$fn</h2>" >> $OUTFN

	# Add paragraph breaks
	# so when the phone wraps log lines
	# it is easy to tell them apart.
	grep -v -f $TMP2 $TMPFN \
	| sed 's/</\&lt;/g' \
	| sed 's/>/\&gt;/g' \
        | sed 's/^/<p>/' \
	>> $OUTFN

    fi
done
N1=$(cat $OUTFN | wc -l)

cat >> $OUTFN << EOF
</body>
</html>
EOF
if [ $N1 -gt $N0 ] ; then
	/usr/sbin/sendmail -t < $OUTFN
fi

rm -fr "$TMPD"
