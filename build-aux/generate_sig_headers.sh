#!/bin/sh


sigfile_list="`echo "#include <signal.h>" | $CPP $CPPFLAGS - |
sed -n -e 's/^#line[ 	].*\"\(.*\)\"/\1/p' \
       -e 's/^#[ 	].*\"\(.*\)\"/\1/p' |
sed 's/\\\\\\\\/\//g' |
awk '{ if ($1 ~ /sig/) files[$1] = $1 }
  END { for (var in files) print var }'`"

if test -z "$sigfile_list"; then
  sigfile_list="/usr/include/sys/iso/signal_iso.h
/usr/include/bsd/sys/signal.h
/usr/include/signum.h
/usr/include/asm/signum.h
/usr/include/asm/signal.h
/usr/include/linux/signal.h
/usr/include/sys/signal.h
/usr/include/bits/signum.h
/dev/null"
fi
for SIGNAL_TRY_H in $sigfile_list
do
  nsigs=`test -f $SIGNAL_TRY_H && \
  grep '#[ 	]*define[ 	][ 	]*SIG[0-9A-Z]*[ 	]*[0-9][0-9]*' $SIGNAL_TRY_H | \
  wc -l | sed 's/[ 	]//g'`
  if test "x$nsigs" != x && test "$nsigs" -ge 7
  then
    SIGNAL_H="$SIGNAL_H $SIGNAL_TRY_H"
  fi
done
if test "x$SIGNAL_H" = x; then
  echo SIGNAL MACROS NOT FOUND:  please report to developers
  exit 1
fi

awk -f $sdir/signames1.awk $SIGNAL_H | $CPP $CPPFLAGS -P - | awk -f $sdir/signames2.awk
