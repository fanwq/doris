#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

export SPARK_MASTER_HOST=doris--spark-iceberg

start-master.sh -p 7077
start-worker.sh spark://doris--spark-iceberg:7077
start-history-server.sh
start-thriftserver.sh --driver-java-options "-Dderby.system.home=/tmp/derby"



ls /mnt/scripts/create_preinstalled_scripts/iceberg/*.sql | xargs -n 1 -I {} bash -c '
    START_TIME=$(date +%s)
    spark-sql --master spark://doris--spark-iceberg:7077 --conf spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions -f {} 
    END_TIME=$(date +%s)
    EXECUTION_TIME=$((END_TIME - START_TIME))
    echo "Script: {} executed in $EXECUTION_TIME seconds"
'

ls /mnt/scripts/create_preinstalled_scripts/paimon/*.sql | xargs -n 1 -I {} bash -c '
    START_TIME=$(date +%s)
    spark-sql --master  spark://doris--spark-iceberg:7077 --conf spark.sql.extensions=org.apache.paimon.spark.extensions.PaimonSparkSessionExtensions -f {} 
    END_TIME=$(date +%s)
    EXECUTION_TIME=$((END_TIME - START_TIME))
    echo "Script: {} executed in $EXECUTION_TIME seconds"
'


touch /mnt/SUCCESS;

tail -f /dev/null
