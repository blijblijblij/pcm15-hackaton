#!/bin/sh
clear

# variables
CLUSTERNAME="blijblijblij"
CLUSTER_SECRET=NiaboeSh9quohw7ZuzeaZieh
HOST_IP_1=192.168.99.100
HOST_IP_2=192.168.99.101
HOST_IP_3=192.168.99.102
HOST_IP_4=192.168.99.103
ZK=${HOST_IP_1}:2181,${HOST_IP_2}:2181,${HOST_IP_3}:2181
MARATHON_VERSION=0.10.1
CHRONOS_VERSION=2.4.0
MESOS_VERSION=0.23.0	#0.24.1
ZOOKEEPER_VERSION=3.4.6

echo "start mesos-m3"
docker rm zookeeper mesos-master slave

echo "---> start zookeeper"
docker run -d \
	-e MYID=3 \
	-e SERVERS=${HOST_IP_1},${HOST_IP_2},${HOST_IP_3} \
	--name=zookeeper --net=host --restart=always \
	mesoscloud/zookeeper:${ZOOKEEPER_VERSION}-ubuntu-14.04

echo "---> start mesos master"
docker run -d \
	-e SECRET=${CLUSTER_SECRET} \
  -e MESOS_CLUSTER=${CLUSTERNAME} \
	-e MESOS_HOSTNAME=${HOST_IP_3} \
	-e MESOS_IP=${HOST_IP_3} \
	-e MESOS_QUORUM=2 \
	-e MESOS_ZK=zk://${ZK}/mesos \
	--name mesos-master --net host --restart always  \
	mesoscloud/mesos-master:${MESOS_VERSION}-ubuntu-14.04

echo "---> start mesos slave"
docker run -d \
	-e SECRET=${CLUSTER_SECRET} \
	-e MESOS_HOSTNAME=${HOST_IP_3} \
	-e MESOS_IP=${HOST_IP_3} \
	-e MESOS_MASTER=zk://${ZK}/mesos \
	-e MESOS_LOG_DIR=/var/log/mesos \
	-e MESOS_LOGGING_LEVEL=INFO \
	-v /sys/fs/cgroup:/sys/fs/cgroup \
	-v /var/run/docker.sock:/var/run/docker.sock \
	--name slave --net host --privileged --restart always \
	mesoscloud/mesos-slave:${MESOS_VERSION}-ubuntu-14.04
