# !/bin/sh -e
# Test logtail does what it should.
# Since: Wed Dec  3 16:55:07 EST 2014
#
#    Copyright (c) 2014, Mark Bucciarelli <mkbucc@gmail.com>
#
#    Permission to use, copy, modify, and/or distribute this software
#    for any purpose with or without fee is hereby granted, provided
#    that the above copyright notice and this permission notice
#    appear in all copies.
#
#    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
#    WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
#    WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
#    THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
#    CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
#    LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
#    NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
#    CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#


LOGTAIL=./logtail
D=./testing

rm -rf $D
mkdir -p $D

fail() {
	echo "FAIL: $1"
	exit 1
}

# logtail outputs two lines added since last run.
cat > $D/1.log << EOF
line1
line2
line3
EOF
$LOGTAIL $D/1.log $D/1.offset > /dev/null
cat >> $D/1.log <<EOF
line4
line5
EOF
$LOGTAIL $D/1.log $D/1.offset > $D/1.act
cat > $D/1.exp << EOF
line4
line5
EOF
diff $D/1.act $D/1.exp && printf "." || fail "didn't see two new lines"

# logtail uses offset.<logfile> as default offset filename
cat > $D/2.log << EOF
line1
line2
line3
EOF
$LOGTAIL $D/2.log > /dev/null
F=offset.2.log
[ -f $D/$F ] && printf "."  || fail "default offset file \"$D/$F\" not created."

# logtail looks for most recent file if inode changes
LF=$D/3.log
cat > $LF << EOF
line1
line2
line3
EOF
$LOGTAIL $LF > /dev/null
cat > $LF << EOF
line4
line5
EOF
cp $LF $LF.1
cat > $LF << EOF
line6
line7
EOF
$LOGTAIL -b $LF > $D/3.act
#$LOGTAIL  $LF > $D/3.act
#cat > $D/3.exp << EOF
#line4
#line5
#line6
#line7
#EOF
#diff $D/3.act $D/3.exp && printf "." || fail "didn't follow log rotation"



printf "\nSUCCESS!\n"
#rm -rf $D
