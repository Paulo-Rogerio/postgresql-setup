#!/usr/bin/env bash

cd $(dirname $0)

for _ in {1..10};
do
  bash stress.sh; 
done

echo "========================================="
echo "Check Lag"
bash 21-check-lag.sh