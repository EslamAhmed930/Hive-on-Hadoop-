FROM ubuntu:22.04 AS base

RUN apt update -y
RUN apt upgrade -y 
RUN apt install -y openjdk-8-jdk
RUN apt install -y ssh
RUN apt install sudo

ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
ENV PATH=$PATH:/usr/local/zookeeper/bin/

ENV TEZ_HOME=/usr/local/tez
ENV PATH=$PATH:$TEZ_HOME/bin

RUN addgroup hadoop 
RUN adduser --disabled-password --ingroup hadoop hadoop

ADD https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz /tmp
RUN tar -xzf /tmp/hadoop-3.3.6.tar.gz -C /usr/local/
RUN mv /usr/local/hadoop-3.3.6 $HADOOP_HOME
RUN chown -R hadoop:hadoop $HADOOP_HOME
ADD https://downloads.apache.org/zookeeper/zookeeper-3.8.4/apache-zookeeper-3.8.4-bin.tar.gz /tmp
RUN tar -xzf /tmp/apache-zookeeper-3.8.4-bin.tar.gz -C /usr/local/
RUN mv /usr/local/apache-zookeeper-3.8.4-bin /usr/local/zookeeper
RUN chown -R hadoop:hadoop /usr/local/zookeeper

ADD https://dlcdn.apache.org/tez/0.10.4/apache-tez-0.10.4-bin.tar.gz /tmp
RUN tar -xzf /tmp/apache-tez-0.10.4-bin.tar.gz -C /usr/local/
RUN mv /usr/local/apache-tez-0.10.4-bin /usr/local/tez
RUN chown -R hadoop:hadoop /usr/local/tez

RUN echo 'hadoop ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

USER hadoop
WORKDIR /home/hadoop
RUN ssh-keygen -t rsa -P "" -f /home/hadoop/.ssh/id_rsa
RUN cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys
RUN chmod 600 /home/hadoop/.ssh/authorized_keys

COPY hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh
COPY core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
COPY hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
COPY mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
COPY yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
COPY workers $HADOOP_HOME/etc/hadoop/workers
COPY zoo.cfg /usr/local/zookeeper/conf/zoo.cfg  
COPY tez-site.xml /usr/local/tez/conf/ 
RUN mkdir /usr/local/zookeeper/data
COPY start.sh /home/hadoop/start.sh
RUN sudo chmod +x /home/hadoop/start.sh
ENTRYPOINT [ "/home/hadoop/start.sh" ]

FROM base AS hive

ADD https://dlcdn.apache.org/hive/hive-4.0.1/apache-hive-4.0.1-bin.tar.gz /tmp
RUN sudo tar -xzf /tmp/apache-hive-4.0.1-bin.tar.gz -C /usr/local/
RUN sudo mv /usr/local/apache-hive-4.0.1-bin /usr/local/hive
RUN sudo chown -R hadoop:hadoop /usr/local/hive
ADD https://jdbc.postgresql.org/download/postgresql-42.7.5.jar /usr/local/hive/lib/ 
RUN sudo chown -R hadoop:hadoop /usr/local/hive/lib/postgresql-42.7.5.jar

# Add Sqoop installation
ADD https://archive.apache.org/dist/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz /tmp
RUN sudo tar -xzf /tmp/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz -C /usr/local/
RUN sudo mv /usr/local/sqoop-1.4.7.bin__hadoop-2.6.0 /usr/local/sqoop
RUN sudo chown -R hadoop:hadoop /usr/local/sqoop


# Add Oracle JDBC driver to Sqoop's lib directory
#ADD https://download.oracle.com/otn-pub/otn_software/jdbc/ojdbc8.jar /usr/local/sqoop/lib/
#UN sudo chown hadoop:hadoop /usr/local/sqoop/lib/ojdbc8.jar



RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    https://download.oracle.com/otn-pub/otn_software/jdbc/1912/ojdbc8.jar \
    -O /usr/local/sqoop/lib/ojdbc8.jar && \
    chown hadoop:hadoop /usr/local/sqoop/lib/ojdbc8.jar

# Set Sqoop environment variables
ENV SQOOP_HOME=/usr/local/sqoop
ENV PATH=$PATH:$SQOOP_HOME/bin

COPY hive-site.xml /usr/local/hive/conf/hive-site.xml

COPY start-hive.sh /home/hadoop/start-hive.sh
RUN sudo chmod +x /home/hadoop/start-hive.sh

ENV HIVE_HOME=/usr/local/hive
ENV PATH=$PATH:$HIVE_HOME/bin
ENTRYPOINT ["/home/hadoop/start-hive.sh"]