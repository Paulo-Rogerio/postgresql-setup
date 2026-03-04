#!/usr/bin/env bash

export TZ=America/Sao_Paulo
export DEBIAN_FRONTEND='noninteractive'

function check(){
    todo=true
    while ${todo};
    do

      pgrep -x apt >/dev/null 2>&1
      ret_apt=$?

      pgrep -x apt-get >/dev/null 2>&1
      ret_apt_get=$?

      pgrep -x dpkg >/dev/null 2>&1
      ret_dpkg=$?

      [[ ${ret_apt} -eq 0 || ${ret_apt_get} -eq 0 || ${ret_dpkg} -eq 0 ]] || export todo=false
      echo "Waiting Apt working...."
      sleep 5
    done
}

check
source ./01-install.sh
source ./02-configure.sh
source ./03-create.sh
source ./07-pgbadger.sh
source ./08-nginx.sh