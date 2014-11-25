# (Required) Set the master program's memory
export SHARK_MASTER_MEM=60g

# (Required) Point to your Scala installation.
export SCALA_HOME="/software/scala-2.10.3/"

# (Required) Point to the patched Hive binary distribution
export HIVE_HOME="/software/hive-0.9.0-bin/"
export HIVE_CONF_DIR="/software/hive-0.9.0-bin/conf"

export HADOOP_HOME="/software/hadoop-2.2.0/"
export MASTER="spark://qp-hm1.damsl.cs.jhu.edu:7070"
export SPARK_HOME="/software/spark-0.9.1/"
export SPARK_MEM=60g


source $SPARK_HOME/conf/spark-env.sh

# Java options
# On EC2, change the local.dir to /mnt/tmp
SPARK_JAVA_OPTS="-Dspark.local.dir=/tmp "
SPARK_JAVA_OPTS+="-Dspark.kryoserializer.buffer.mb=10 "
SPARK_JAVA_OPTS+="-verbose:gc -XX:-PrintGCDetails -XX:+PrintGCTimeStamps "
export SPARK_JAVA_OPTS
