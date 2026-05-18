#!/usr/bin/env bash

cd $(dirname $0)

source create-infra/01-create.sh
source create-infra/02-check.sh
source create-infra/03-insert.sh
source create-infra/04-select.sh
source create-infra/05-dump-restore.sh
source create-infra/06-check.sh