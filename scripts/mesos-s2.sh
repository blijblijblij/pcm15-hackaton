#!/bin/sh
clear

# variables
CLUSTERNAME="blijblijblij"
CLUSTER_SECRET=NiaboeSh9quohw7ZuzeaZieh
HOST_IP_1=192.168.99.100
HOST_IP_2=192.168.99.101
HOST_IP_3=192.168.99.102
HOST_IP_5=192.168.1.12
ZK=${HOST_IP_1}:2181,${HOST_IP_2}:2181,${HOST_IP_3}:2181
MARATHON_VERSION=0.11.0 #0.10.1
CHRONOS_VERSION=2.4.0
MESOS_VERSION=0.23.0	#0.24.1
ZOOKEEPER_VERSION=3.4.6

echo "start mesos-s1"
docker rm slave

echo "---> start mesos slave"
docker run -d \
	-e SECRET=${CLUSTER_SECRET} \
	-e MESOS_HOSTNAME=aramaki \
	-e MESOS_IP=${HOST_IP_5} \
	-e MESOS_MASTER=zk://${ZK}/mesos \
	-e MESOS_LOG_DIR=/var/log/mesos \
	-e MESOS_LOGGING_LEVEL=INFO \
	-v /sys/fs/cgroup:/sys/fs/cgroup \
	-v /var/run/docker.sock:/var/run/docker.sock \
	--name slave --net host --privileged --restart always \
	mesoscloud/mesos-slave:${MESOS_VERSION}-ubuntu-14.04
