#!/bin/sh
clear

# variables
CLUSTERNAME="blijblijblij"
CLUSTER_SECRET=NiaboeSh9quohw7ZuzeaZieh
HOST_IP_1=192.168.1.171
HOST_IP_2=192.168.1.12
HOST_IP_3=192.168.99.102
HOST_IP_4=192.168.99.103
ZK=${HOST_IP_1}:2181,${HOST_IP_2}:2181,${HOST_IP_2}:2181
MARATHON_VERSION=0.11.0 #0.10.1
CHRONOS_VERSION=2.4.0
MESOS_VERSION=0.23.0	#0.24.1
ZOOKEEPER_VERSION=3.4.6

echo "start mesos-m1"
docker rm zookeeper mesos-master slave marathon chronos

echo "---> start zookeeper"
docker run -d \
	-e MYID=1 \
	-e SERVERS=${HOST_IP_1},${HOST_IP_2} \
	--name=zookeeper --net=host --restart=always \
	mesoscloud/zookeeper:${ZOOKEEPER_VERSION}-ubuntu-14.04

echo "---> start mesos master"
docker run -d \
	-e SECRET=${CLUSTER_SECRET} \
	-e MESOS_CLUSTER=${CLUSTERNAME} \
	-e MESOS_HOSTNAME=${HOST_IP_1} \
	-e MESOS_IP=${HOST_IP_1} \
	-e MESOS_QUORUM=1 \
	-e MESOS_ZK=zk://${ZK}/mesos \
	--name mesos-master --net host --restart always  \
	mesoscloud/mesos-master:${MESOS_VERSION}-ubuntu-14.04

echo "---> start mesos slave"
docker run -d \
	-e SECRET=${CLUSTER_SECRET} \
	-e MESOS_HOSTNAME=${HOST_IP_1} \
	-e MESOS_IP=${HOST_IP_1} \
	-e MESOS_MASTER=zk://${ZK}/mesos \
	-e MESOS_LOG_DIR=/var/log/mesos \
	-e MESOS_LOGGING_LEVEL=INFO \
	-v /sys/fs/cgroup:/sys/fs/cgroup \
	-v /var/run/docker.sock:/var/run/docker.sock \
	--name slave --net host --privileged --restart always \
	mesoscloud/mesos-slave:${MESOS_VERSION}-ubuntu-14.04

echo "---> start marathon"
docker run -d \
	-e SECRET=${CLUSTER_SECRET} \
	-e MARATHON_HOSTNAME=${HOST_IP_1} \
	-e MARATHON_HTTPS_ADDRESS=${HOST_IP_1} \
	-e MARATHON_HTTP_ADDRESS=${HOST_IP_1} \
	-e MARATHON_MASTER=zk://${ZK}/mesos \
	-e MARATHON_ZK=zk://${ZK}/marathon \
	--name marathon --net host --restart always \
	mesoscloud/marathon:${MARATHON_VERSION}-ubuntu-15.04

echo "---> start chronos"
docker run -d \
	-e SECRET=${CLUSTER_SECRET} \
	-e CHRONOS_HTTP_PORT=4400 \
	-e CHRONOS_MASTER=zk://${ZK}/mesos \
	-e CHRONOS_ZK_HOSTS=${ZK} \
	--name chronos --net host --restart always \
	mesoscloud/chronos:${CHRONOS_VERSION}-ubuntu-14.04
