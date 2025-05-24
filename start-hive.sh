#!/bin/bash



if [ ! -f /metastore_initialized ]; then
  echo "Initializing Hive metastore schema..."
  schematool -dbType postgres -initSchema

  hdfs dfs -mkdir -p /apps/tez
  hdfs dfs -put /usr/local/tez/share/tez.tar.gz /apps/tez/
fi



if [[ "$HOSTNAME" == "hive-metastore" ]]; then
  echo "Starting Hive Metastore service..."
  hive --service metastore
elif [[ "$HOSTNAME" == "hive-server2" ]]; then
  echo "Starting HiveServer2..."
  hive --service hiveserver2
else
  echo "Invalid HIVE_ROLE: must be 'metastore' or 'hiveserver2'"
  exit 1
fi
     
sleep infinity 