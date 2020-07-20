#!/bin/bash
# argument is list of filters

FILTERS=$*

ERRORS_COUNT=0
PASSED_COUNT=0
SKIPPED_COUNT=0
EXPECTED_COUNT=0

let err=0

for d in $FILTERS; do
  let "EXPECTED_COUNT++"
  make --no-print-directory -C $d test
  if [ $? -eq 0 ]; then
    let "PASSED_COUNT++"
    echo "✓ $d"
  else
    let "ERRORS_COUNT++"
    echo "✗ $d"
  fi
done

echo ""
echo "⚖ Summary"
echo "✓ ${PASSED_COUNT} passed"
[ ${ERRORS_COUNT} = 0 ] || echo "✗ ${ERRORS_COUNT} errors"
exit ${ERRORS_COUNT}
