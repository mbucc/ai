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

mkdir -p $D

# Test that a 
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
diff $D/1.act $D/1.exp


# If we get an error, the -e switch will abort script before this line
# so we can inspect data.
rm -rf $D
