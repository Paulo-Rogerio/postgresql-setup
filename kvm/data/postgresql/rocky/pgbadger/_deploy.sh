#!/usr/bin/env bash

export TZ=America/Sao_Paulo
export PGVERSION=17

function check(){
    todo=true
    while ${todo};
    do

      pgrep -x dnf >/dev/null 2>&1
      ret_dnf=$?

      pgrep -x yum >/dev/null 2>&1
      ret_yum=$?

      [[ ${ret_dnf} -eq 0 || ${ret_yum} -eq 0 ]] || export todo=false
      echo "Waiting Dnf working...."
      sleep 10
    done
}

check
source ./01-install.sh
source ./02-create.sh
source ./06-pgbadger.sh
source ./07-nginx.sh