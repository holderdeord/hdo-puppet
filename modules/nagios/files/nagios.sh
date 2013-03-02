#!/bin/bash
SUM=0

cd nagioschecks

for check in $(ls)
do
  ./$check
  RETCODE=$?
  if [ $RETCODE -gt 0 ]
  then
    SUM=$(( $SUM + RETCODE ))
  fi
done

if [ $SUM -gt 1 ]
then
  exit 2
else
  exit $SUM
fi

