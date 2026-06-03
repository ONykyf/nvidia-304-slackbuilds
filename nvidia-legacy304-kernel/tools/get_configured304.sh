#!/bin/sh

export LC_ALL=C

cat conftest.sh | egrep 'echo .* append_conftest ' | \
  sed -r 's/^ *echo //' | \
  cut -f 2 -d '"' | sed 's/\"//g' | \
  grep -v '\$' | grep -v '(' | \
  cut -f 2 -d ' '\
  > got_append_conftest304.txt

cat conftest.sh | grep 'compile_check_conftest ' | \
  sed -r 's/^ *compile_check_conftest //' | \
  cut -f 2 -d ' ' | sed 's/\"//g' \
  > got_compile_conftest304.txt

cat conftest.sh | egrep 'echo "#(define|undef) .* >> conftest.h'  | \
  sed -r 's/^ *echo \"#(define|undef) ([^ \"]*).*$/\2/' | \
  > got_echo_conftest304.txt

cat got_append_conftest304.txt got_compile_conftest304.txt got_echo_conftest304.txt | \
  egrep '^NV_'| sort | uniq > got_configured304.txt


