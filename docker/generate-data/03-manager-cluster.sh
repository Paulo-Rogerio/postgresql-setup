#!/usr/bin/env bash

source manager-cluster/14-update-pg13.sh
source manager-cluster/17-status-subscriber.sh
source manager-cluster/21-check-lag.sh
source manager-cluster/22-nologin.sh
source manager-cluster/24-sequence.sh
source manager-cluster/25-update-pg18.sh
source manager-cluster/26-insert.sh
source manager-cluster/13-select-pg18.sh
source create-cluster/12-drop-subscriber.sh
source create-cluster/09-drop-publication.sh