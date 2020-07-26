#!/bin/sh
# argument is list of filters
FILTERS=$*

errors_count=0
passed_count=0

for d in $FILTERS; do
  make --no-print-directory -C $d test
  if [ $? -eq 0 ]; then
    passed_count=$(($passed_count + 1))
    printf "✓ $d\n"
  else
    errors_count=$(($errors_count + 1))
    printf "✗ $d\n"
  fi
done

printf "\n"
printf "⚖ Summary\n"
printf "✓ ${passed_count} passed\n"
[ ${errors_count} = 0 ] || printf "✗ ${errors_count} errors\n"
exit ${errors_count}
