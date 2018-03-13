#!/usr/bin/env bash

shopt -s expand_aliases

# alias "[[ -e"="[[ test -e "

function should_i(){
  echo "$@"
  return 0
}

function yes() {
  echo "yes"
}

# if [[ should_i -e Gemfile ]]; then
#   echo "did not override"
# fi

FILE=Gemfile

# -e $FILE && yes

test -e $FILE && yes

[ -e $FILE ] && yes

[[ -e $FILE ]] && yes

# if -e $FILE; then
#   yes
# fi

if test -e $FILE; then
  yes
fi

if [ -e $FILE ]; then
  yes
fi

if [[ -e $FILE ]]; then
  yes
fi

