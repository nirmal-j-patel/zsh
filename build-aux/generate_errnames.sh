#!/bin/sh

set -x

errfile_list="`echo "#include <errno.h>" | $CPP $CPPFLAGS - |
sed -n -e 's/^#line[ 	].*\"\(.*\)\"/\1/p' \
       -e 's/^#[ 	0-9].*\"\(.*\)\"/\1/p' |
sed 's/\\\\\\\\/\//g' |
awk '{ if ($1 ~ /err/) files[$1] = $1 }
  END { for (var in files) print var }'`"

for ERRNO_TRY_H in $errfile_list /dev/null
do
  nerrs=`test -f $ERRNO_TRY_H && \
  grep -E '#[ 	]*define[ 	][ 	]*E[0-9A-Z]*[ 	]*(_HURD_ERRNO )?\(?[_A-Z0-9]' $ERRNO_TRY_H | \
  wc -l | sed 's/[ 	]//g'`
  if test "x$nerrs" != x && test "$nerrs" -ge 1
  then
    ERRNO_H="$ERRNO_H $ERRNO_TRY_H"
  fi
done
if test x"$ERRNO_H" = x; then
  echo ERROR MACROS NOT FOUND:  please report to developers
  exit 1
fi

awk -f $sdir/errnames1.awk $ERRNO_H | $CPP $CPPFLAGS -P - | awk -f $sdir/errnames2.awk
