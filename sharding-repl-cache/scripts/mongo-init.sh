#!/bin/bash

# Инициализация конфигурационного сервера
docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
rs.initiate({
    _id: "config_server",
    configsvr: true,
    members: [
        { _id: 0, host: "configSrv:27017" }
    ]
});
EOF

echo "Config server initialized."

# Инициализация первого шарда с репликацией
docker compose exec -T shard1_1 mongosh --port 27018 --quiet <<EOF
rs.initiate({
    _id: "shard1",
    members: [
        { _id: 0, host: "shard1_1:27018" },
        { _id: 1, host: "shard1_2:27018" },
        { _id: 2, host: "shard1_3:27018" }
    ]
});
EOF

echo "Shard1 replication set initialized."

# Инициализация второго шарда с репликацией
docker compose exec -T shard2_1 mongosh --port 27019 --quiet <<EOF
rs.initiate({
    _id: "shard2",
    members: [
        { _id: 0, host: "shard2_1:27019" },
        { _id: 1, host: "shard2_2:27019" },
        { _id: 2, host: "shard2_3:27019" }
    ]
});
EOF

echo "Shard2 replication set initialized."

# Настройка роутера и заполнение тестовыми данными
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
sh.addShard("shard1/shard1_1:27018,shard1_2:27018,shard1_3:27018");
sh.addShard("shard2/shard2_1:27019,shard2_2:27019,shard2_3:27019");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name": "hashed" });

use somedb;
for (var i = 0; i < 1000; i++) db.helloDoc.insert({ age: i, name: "ly" + i });
print("Document count:", db.helloDoc.countDocuments());
EOF

echo "Router initialized and test data inserted."
