# VLAN management LAB

## Purpose
The main purpose of this LAB is to show how MSActivator can manage VLAN configuration.
Achieved level of abstraction allows human controlling l2-switch as a typical swich despite the fact that this switch is a pure linux machine.

             +-------+        +-------+        +-------+        +-------+
             |       |        |       |        |       |        |       |
             | pc_01 |        | pc_02 |        | pc_03 |        | pc_04 |
             |       |        |       |        |       |        |       |
             +-------+        +-------+        +-------+        +-------+
           +vlandefault+    +vlandefault+    +-vlan 100--+    +-vlan 200--+
           +-untagged--+    +-untagged--+    +-untagged--+    +---tagged--+
                 |                |                |                |
                 |                |                |                |
     +--------------------------------------------------------------------------+
     |        |eth0 |          |eth1 |          |eth2 |          |eth3 |        |
     |        +-----+          +-----+          +-----+          +-----+        |
     |                                                                          |
     +--------------------------------------------------------------------------+

## Diagram

    +------------------------+                       +------------------------+
    | pc_01: 172.20.0.141/24 |                       | pc_02: 172.20.0.142/24 |
    |    10.222.222.11/24    |                       |    10.222.222.12/24    |
    +-----------+------------+                       +------------+-----------+
                |                                                 |
       default vlan untagged                            default vlan untagged
                |                                                 |
                |            +-----------------------+            |
                |            |switch 172.20.0.145/24 |            |
                +------------+     +-----------+     +------------+
                             |     | VLAN:     |     |
                             |     | default   |     |
                             |     | vlan_100  |     |
                +------------+     | vlan_200  |     +------------+
                |            |     +-----------+     |            |
                |            +-----------------------+            |
        vlan 100 untagged                                 vlan 200 tagged
                |                                                 |
                |                                                 |
    +-----------+------------+                       +------------+-----------+
    |    10.222.222.13/24    |                       |    10.222.222.14/24    |
    | pc_03: 172.20.0.143/24 |                       | pc_04: 172.20.0.144/24 |
    +------------------------+                       +------------------------+

### Credentials:
For all the containers:
USERNAME: root
PASSWORD: root123

## Scenario
0. Default state:
 - pc_01, pc_02 - can ping each other, placed in default_vlan
 - pc_03 is not reachable, placed in 100 vlan
 - pc_03 is not reachable, placed in 200 vlan, encapsulates frames with 200 802.1q tag.

1. Set pc_01 in vlan 100 and ping pc_03

2. Set pc_01 in vlan 200(untagged) and ping pc_04
 - ensure with TCP dump packets are encapsulated/de-encapsulated properly

3. Set pc_01 in vlan 200(tagged) and ping pc04
 - note: pc_01 should have tagging enabled

## Files description
### [docker-compose.yml](docker-compose.yml)
 - Docker compose file presumes using "quickstart_default" network for management plane.
 - Docker requires numbered network to be used, thus intranet network created, IP-prefixes allocated, but IP-prefixes will be replaced.
 - pc_ services have network interfaces connected, network interface order matters, but Docker makes this order **random**, [switch.sh](switch.sh#L3) and [pc.sh](pc.sh#L3) fixes this behaviour.
 - Intranet networks for data plane and demo use-cases.
 - "quickstart_default" networkj for control.

### [pc.dockerfile](pc.dockerfile)
Creates **PC** container based on Alpine v3.12 linux, packages:
 - openssh (to take control over PC)
 Uses [ETRYPOINT script](pc.sh).
### [switch.dockerfile](switch.dockerfile)
Creates **SWITCH** container based on Alpine v3.12 linux, packages:
 - openssh (to take control over SWITCH)
 - bash (to make [patch script](port) being executed)
 - tcpdump (capture/verify tagged traffic)
Uses [ETRYPOINT script](switch.sh)
### [pc.sh](pc.sh)
WORKAROUND to assing certain network addresses to interfaces randomized by docker.
consider "eht0" interface one that have 172.20.0.x address assigned by Docker DHCP.
consider "eht1" interface one that have 10.222.x.y address assigned by Docker DHCP. 
```bash
# WORKAROUND FOR UNCERTAIN DOCKER INTERFACE ORDER
eth0=$(ifconfig | grep -B1 "inet addr:172.20.0." | awk '$1!="inet" && $1!="--" {print $1}')
eth1=$(ifconfig | grep -B1 "inet addr:10.222." | awk '$1!="inet" && $1!="--" {print $1}')

# CHANGE IP ADDRESS TO THE PROPER ONE AND MAKE 4th MACHINE TAGGED
NUM=`echo $HOSTNAME | grep -E -o '[1-9]'`
IPADDR=`ifconfig $eth1 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}'`
NEW_IPADDR='10.222.222.1'$NUM'/24'
```
For PC_04 here is 802.1q tagging enabling, for PC_01,PC_02,PC_03 - untagged:
```bash
if [ $NUM = '4' ]; then
    ip a d $IPADDR dev $eth1
    ip link add link $eth1 name $eth1.200 type vlan id 200
    ip a a $NEW_IPADDR dev $eth1.200
    iplink set $eth1.200 up
else
    ip a d $IPADDR dev $eth1
    ip a a $NEW_IPADDR dev $eth1
fi
```
### [switch.sh](switch.sh)
Assings certain network addresses to interfaces randomized by docker.
Creats tagged interface faced on PC_04.
Uses bridge-utils to create network broadcast domains (VLANs).

### [port](port)
This is the patch to retrieve appropriate network interface information:
interface-id | interface name | vlan name | 802.1q tag |
-------------|----------------|-----------|------------- 
eth2 | eth2 | vlan_100 | untagged
eth3.200 | eth3 | vlan_200 | 200
eth0 | eth0 | vlan_default | untagged
eth1 | eth1 | vlan_default | untagged
eth3 | eth3 | vlan_default | untagged
