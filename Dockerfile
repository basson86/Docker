FROM ubuntu:14.04
RUN apt-get update

# Utils
RUN apt-get install -y dnsutils vim links git ssh

# Add configuration files
# Nsswitch: Prefer DNS over hosts file

# May be allowed to edit hosts file inside docker now
# making this unnecessary
ADD network-config/nsswitch.conf /etc/

# SSH Configuration
ADD ssh-config/.bashrc /root/
RUN mkdir /root/.ssh/
ADD ssh-config/sshd_config /etc/ssh/
ADD ssh-config/ssh_config /etc/ssh/
ADD ssh-config/id_rsa /root/.ssh/
ADD ssh-config/id_rsa.pub /root/.ssh/
ADD ssh-config/authorized_keys /root/.ssh/
RUN chown root /root/.ssh/authorized_keys
RUN chown root /root/.ssh/id_rsa
RUN chmod 400 /root/.ssh/id_rsa
RUN chown root /root/.ssh/id_rsa.pub
RUN chmod 400 /root/.ssh/id_rsa.pub

# Install Java
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get update
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
RUN apt-get install -y oracle-java7-installer 

# Install Scala
RUN wget http://www.scala-lang.org/files/archive/scala-2.10.3.tgz
RUN mkdir /software
RUN tar xvfz scala-2.10.3.tgz
RUN mv scala-2.10.3 /software/

# Install Hadoop
RUN wget https://archive.apache.org/dist/hadoop/core/hadoop-2.2.0/hadoop-2.2.0.tar.gz
RUN tar xvzf hadoop-2.2.0.tar.gz -C software/

RUN mkdir -p /data/hadoop
RUN mkdir -p /data/namenode
RUN mkdir -p /data/datanode

# Install Spark
RUN wget http://archive.apache.org/dist/spark/spark-0.9.1/spark-0.9.1-bin-hadoop2.tgz
RUN tar xvfz spark-*-bin-*.tgz
RUN mv spark-*-bin-*/ /software/spark-0.9.1

# Install Shark
RUN wget https://s3.amazonaws.com/spark-related-packages/shark-0.9.1-bin-hadoop2.tgz
RUN tar xvfz shark-*-bin-*.tgz
RUN mv shark-0.9.1-bin-hadoop2 /software/

# amplab Hive (required by Shark)
RUN wget https://github.com/amplab/shark/releases/download/v0.8.1/hive-0.9.0-bin.tgz
RUN tar xvzf hive-0.9.0-bin.tgz
RUN mv hive-0.9.0-bin /software

# protobuf patch
RUN mkdir /temp2
WORKDIR /temp2
RUN jar -xf /software/shark-0.9.1-bin-hadoop2/lib_managed/jars/edu.berkeley.cs.shark/hive-exec/hive-exec-0.11.0-shark-0.9.1.jar
RUN rm -rf com/
RUN jar -cf hive-exec-0.11.0-shark-0.9.1.jar .
RUN mv hive-exec-0.11.0-shark-0.9.1.jar /software/shark-0.9.1-bin-hadoop2/lib_managed/jars/edu.berkeley.cs.shark/hive-exec/

# Do all of this through git?
# Configuration Files:

ADD startup-scripts/master_startup.sh /
ADD startup-scripts/slave_startup.sh /
RUN chmod +x /master_startup.sh
RUN chmod +x /slave_startup.sh

# Hadoop Yarn
ADD hadoop-config/mapred-site.xml /software/hadoop-2.2.0/etc/hadoop/
ADD hadoop-config/core-site.xml /software/hadoop-2.2.0/etc/hadoop/
ADD hadoop-config/slaves /software/hadoop-2.2.0/etc/hadoop/
ADD hadoop-config/yarn-site.xml /software/hadoop-2.2.0/etc/hadoop/
ADD hadoop-config/hdfs-site.xml /software/hadoop-2.2.0/etc/hadoop/

# Spark
ADD hadoop-config/slaves /software/spark-0.9.1/conf/
ADD hadoop-config/spark-env.sh /software/spark-0.9.1/conf/

## Hive / Shark
ADD hadoop-config/hive-site.xml /software/hive-0.9.0-bin/conf/
ADD hadoop-config/shark-env.sh /temp/shark-env.sh /software/shark-0.9.1-bin-hadoop2/conf/

# Benchmark
RUN mkdir /amplab
RUN git clone https://github.com/amplab/benchmark /amplab/benchmark
ADD benchmark-config/prepare.sh /amplab/benchmark/runner/
RUN chmod +x /amplab/benchmark/runner/
ADD benchmark-config/prepare_benchmark.py /amplab/benchmark/runner/
ADD benchmark-config/run.sh /amplab/benchmark/runner/
RUN chmod +x /amplab/benchmark/runner/
ADD benchmark-config/run_query.py /amplab/benchmark/runner/
