#!/bin/sh

export LC_ALL=C

egrep 'defined' *.[ch] | \
  sed -r 's/^.*defined ?\(([^\)]*)\).*defined ?\(([^\)]*)\).*$/\1\n\2/' | \
  sed -r 's/^.*defined ?\(([^\)]*)\).*$/\1/' \
  > got_defined304.tmp1

# typedef not handled automatically
echo NV_ACPI_EVALUATE_INTEGER_PRESENT >> got_defined304.tmp1

# nowhere in the code, but does not hurt
echo NV_VM_FAULT_PRESENT >> got_defined304.tmp1

egrep '#if ?\(|#elif ?\(' *.[ch] | \
  sed -r 's/^.*#if ?\(([^ ]*) .*$/\1/' | \
  sed -r 's/^.*#elif ?\(([^ ]*) .*$/\1/' \
  > got_defined304.tmp2

egrep '^ *# *ifdef |^ *# *ifndef ' *.[ch] | \
  sed -r 's/^.*# *ifdef ([^ ]*)$/\1/' | \
  sed -r 's/^.*# *ifndef ([^ ]*)$/\1/' \
  > got_defined304.tmp3

cat got_defined304.tmp1 got_defined304.tmp2 got_defined304.tmp3 | egrep '^NV_' | \
  sort | uniq | grep -v ':' > got_defined304.txt

rm -f got_defined304.tmp1 got_defined304.tmp2 got_defined304.tmp3


