#!/usr/bin/env bash

export PGPASSWORD="postgres"

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

    WHEN pg_is_in_recovery()
    THEN COALESCE(
      pg_last_wal_receive_lsn(),
      pg_last_wal_replay_lsn()
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
  echo "[[ Sucessfully ]] - Cluster Syncronizado" || \
  echo "[[ Error ]] - Cluster Dessincronizado"

