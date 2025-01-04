#!/bin/bash

# Функция для выполнения команды в указанном шарде
check_shard() {
  local shard_name=$1
  local port=$2

  echo "Проверяем $shard_name на порту $port..."
  docker compose exec -T "$shard_name" mongosh --port "$port" --quiet <<EOF
use somedb;
const count = db.helloDoc.countDocuments();
print("Количество документов в $shard_name: " + count);
exit();
EOF
}

# Проверка на shard1
check_shard "shard1" 27018

# Проверка на shard2
check_shard "shard2" 27019
