#!/bin/bash
# argument is list of filters

FILTERS=$*
let err=0
for d in $FILTERS ; do
    make --no-print-directory -C $d test
    if [ $? -eq 0 ]; then
    	echo "PASS $d"
    else
    	echo "FAIL $d"
	err=1
    fi
done
exit $err

