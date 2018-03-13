#!/usr/bin/env bash

# create the setenv.sh file if it doesn't exist
if ! [ -e setenv.sh ]; then
  echo "Creating setenv.sh file with PGUSER=$(whoami)"
#   echo "#!/usr/bin/env bash
# export PGUSER=$pgUser
# export PGPASSWORD=" > setenv.sh
fi

test -e setenv.sh && echo "yeah!"

source setenv.sh
