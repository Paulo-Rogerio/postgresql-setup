#!/usr/bin/env bash

export PGPASSWORD="postgres"
export red=$'\e[31;01m'
export green=$'\e[32;01m'
export reset=$'\e[0m'

# Até onde esse cluster está sincronizado? => LSN (Log Sequence Number), posição do Wal.

# É uma subscription? Se sim, consulto o pg_stat_subscription para recuperar o Último LSN vindo do publisher.

# pg_current_wal_lsn() =>  NÃO representa a ultima sincronização, e o WAL do proprio subscriber.
# pg_current_wal_lsn() =>  Representa o LSN atual do cluster.


query="SELECT
  CASE

    WHEN EXISTS (
      SELECT 1
      FROM pg_stat_subscription
    )
    THEN (
      SELECT latest_end_lsn
      FROM pg_stat_subscription
      LIMIT 1
    )
    ELSE pg_current_wal_lsn()

  END AS lsn;"

export lsbPublication=$(psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5433 \
  -At <<EOF
${query}
EOF
)

export lsbSubscription=$(psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5434 \
  -At <<EOF
${query}
EOF
)

[[ "${lsbPublication}" == "${lsbSubscription}" ]] && \
  echo "${green} [[ Sucessfully ]] - Cluster Syncronizado ${reset}" || \
  echo "${red} [[ Error ]] - Cluster Dessincronizado ${reset}"

