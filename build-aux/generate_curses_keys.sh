#!/bin/sh

# set -x

curses_list="`echo "#include <ncurses.h>" | $CPP $CPPFLAGS - |
sed -n -e 's/^#line[ 	].*\"\(.*\)\"/\1/p' \
       -e 's/^#[ 	0-9].*\"\(.*\)\"/\1/p' |
sed 's/\\\\\\\\/\//g' |
awk '{ if ($1 ~ /\.h/) files[$1] = $1 }
  END { for (var in files) print var }'`"

for CURSES_TRY_H in $curses_list /dev/null
do
  nkeys=`test -f $CURSES_TRY_H && \
  grep -E '#[ 	]*define[ 	][ 	]*KEY_' $CURSES_TRY_H | \
  wc -l | sed 's/[ 	]//g'`
  if test "x$nkeys" != x && test "$nkeys" -ge 10
  then
    CURSES_KEYS_H=$CURSES_TRY_H
    break
  fi
done
if test "x$CURSES_KEYS_H" = x; then
  echo CURSES KEYS NOT FOUND:  please report to developers
  exit 1
fi

awk -f $sdir/curses_keys.awk $CURSES_KEYS_H /dev/null
