#!/bin/bash

# Проверка каждой реплики в шарде
check_shard_replica() {
  local shard_name=$1
  local replica=$2
  local port=$3

  echo "Проверяем реплику $replica для $shard_name на порту $port..."
  docker compose exec -T "$replica" mongosh --port "$port" --quiet <<EOF
use somedb;
const count = db.helloDoc.countDocuments();
print("Количество документов в реплике $replica ($shard_name): " + count);
exit();
EOF
}

# Проверка реплик для shard1
check_shard_replica "shard1" "shard1_1" 27018
check_shard_replica "shard1" "shard1_2" 27018
check_shard_replica "shard1" "shard1_3" 27018

# Проверка реплик для shard2
check_shard_replica "shard2" "shard2_1" 27019
check_shard_replica "shard2" "shard2_2" 27019
check_shard_replica "shard2" "shard2_3" 27019
