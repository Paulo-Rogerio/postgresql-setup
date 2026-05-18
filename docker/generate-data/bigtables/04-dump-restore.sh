#!/usr/bin/env bash

# -Fd (Format Directory). Modifica o formato de saída para Diretório. Em vez de gerar um único arquivo .sql gigante.
# -j 16  (Jobs) Ativa o paralelismo. O pg_dump abrirá 16 conexões simultâneas com o banco de dados para despejar as tabelas ao mesmo tempo.

# 1. Faz o dump em paralelo para uma pasta local usando o snapshot
# pg_dump \
#   -U "postgres" \
#   -h localhost \
#   -d "app" \
#   -p 5433 \
#   -Fd \
#   -j 16 \
#   --snapshot='000003A1-1' \
#   --table=sistemas.usuarios \
#   --table=sistemas.pedidos \
#   --table=sistemas.produtos \
#   -f /tmp/meu_dump_paralelo

# 2. Restaura no servidor de destino também em paralelo
# pg_restore \
#   -U "postgres" \
#   -h localhost \
#   -d "app" \
#   -p 5434 \
#   -j 16 \
#   /tmp/meu_dump_paralelo

# 3. Iterando num array com as tabelas ignoradas.
# TABELAS=(
#   "app.people"
#   "app.logs"
# )

# PARAMS_INCLUDE=""
# for tabela in "${TABELAS[@]}"; do
#   PARAMS_INCLUDE="${PARAMS_INCLUDE} --table=${tabela}"
# done

# pg_dump \
#   -U "postgres" \
#   -h localhost \
#   -d "app" \
#   -p 5433 \
#   --snapshot='000003A1-1' \
#   ${PARAMS_INCLUDE} \


[[ -z $1 ]] && echo "SnapShot não informado. Usage: $0 xxxxxxx3-xxxxxx4D-1" && exit 1

export snap=$1
export PGPASSWORD="postgres"

echo "========================================="
echo "Export / Import Tabelas Grandes"
pg_dump \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5433 \
  --data-only \
  --disable-triggers \
  --snapshot="${snap}" \
  --table=sistemas.people | \
psql \
  -U "postgres" \
  -h localhost \
  -d "app" \
  -p 5434


