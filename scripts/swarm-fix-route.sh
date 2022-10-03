#!/usr/bin/env bash
#set -x
set -e
unset ID
unset NET_ID
unset OVERLAY_NET_PREFIX
unset MATCH
unset IFACE
unset NS_ID
unset LB_NET_ID
unset LB_NS_ID
unset NS_ID_LONG
unset NS_ID_SHORT
unset CONT_ID
unset RSORTED_RULES
unset RUN_DIR
unset NETNS_DIR
unset DOCKER_NETWORK_1
unset DOCKER_NETWORK_2
unset rule
unset RULES
unset INGRESS_NS
unset MSA_SMS
unset MSA_SMS_HERE
unset MSA_FRONT_HERE
unset MSA_FRONT
unset MSA_PREFIX
unset MSA_FRONT_IFACE
unset MSA_SMS_IFACE
unset MSA_FRONT_NS_ID
unset MSA_SMS_NS_ID

RUN_DIR="/var/run"
NETNS_DIR="/var/run/docker/netns"
DOCKER_NETWORK_1="ingress"
DOCKER_NETWORK_2="a_default"
INGRESS_NS="ingress_sbox"
MSA_SMS="msa-sms"
MSA_FRONT="msa-front"

function print_help {
echo "###################################################################"
echo "###################################################################"
echo "###################################################################"
echo "###################################################################"
echo ""
echo "Script to update docker swarm network configuration"
echo ""
echo "Options:"
echo "[-s]"
echo "shows current configuration"
echo "example: ./script.sh -s"
echo "[-a]"
echo "updates (adds) configuration"
echo "example: ./script.sh -a"
echo "[-d]"
echo "updates (reverts) configuration"
echo "example: ./script.sh -d"
echo "[-h]"
echo "prints help"
echo ""
echo "###################################################################"
echo "###################################################################"
echo "###################################################################"
echo "###################################################################"
}

function create_ns_symlink {
  # $1 - supposed to be "/var/run"
  # $2 - supposed to be "/var/run/docker/netns"

 # if [ -d "$1" ] && [ -d "$2" ]; then
   if [ -d "$1" ]; then
    cd "$1"
    if [ -d "netns" ];then
	     echo "Deleting default netns"
	    rm -rf netns
    fi
    sudo ln -sfn "$2" netns
        if [ $? -eq 0 ]; then
          echo "Symlink successfully created"
        else
          echo "WARNING: Can't create symlink."
          exit 1
        fi
    cd - > /dev/null
  else
    echo "WARNING: $1 or $2 not found."
  fi
}

function check_ns {
  # $1 - supposed to be "/var/run/docker/netns"
  # $2 - docker network name

  ls -lah $1 > /dev/null
  if [ $? -eq 0 ]; then
    local MATCH=$(ls -lah $1 | grep $2 | wc -l)
    if [ $MATCH -eq 1 ]; then
      echo $2
    else
      echo "WARNING: $1 namespace not found. "
    fi
  else
    echo "WARNING: $1 directory not found. "
  fi
}


function check_lb_ns {
  # $1 - supposed to be "/var/run/docker/netns"
  # $2 - docker network id
  # namespace format: lb_ + $2(with last 3 symbols cutted off)

  local ID=$2
  local NS_ID="lb_${ID::-3}"
  ls -lah $1 > /dev/null
  if [ $? -eq 0 ]; then
    local MATCH=$(ls -lah $1 | grep $NS_ID | wc -l)
    if [ $MATCH -eq 1 ]; then
      echo $NS_ID
    else
      echo "WARNING: $1 namespace not found."
    fi
  else
    echo "WARNING: $1 directory not found."
  fi
}

function add_default_route {
  # $1 - namespace id

  sudo ip netns exec $1 ip r > /dev/null
  if [ $? -eq 0 ]; then
    local MATCH=$(sudo ip netns exec $1 ip r | grep default | wc -l)
      if [ $MATCH -eq 1 ]; then
        echo "Default route already exists"
      else
        sudo ip netns exec $1 ip r a default dev eth0
        if [ $? -eq 0 ]; then
          echo "Default rule successfully added."
        else
          "WARNING: Can't add default route to $1 namespace."
        fi
      fi
  else
    echo "WARNING: Can't add default route to $1 namespace."
  fi
}

function add_514_nat_exception {
  # $1 - namespace id
  # $2 - destinnation ip prefix

  sudo ip netns exec $1 iptables -t nat -nvL POSTROUTING --line-numbers > /dev/null
  if [ $? -eq 0 ]; then
    sudo ip netns exec $1 iptables -t nat -I POSTROUTING 2 -m ipvs --ipvs -s 0.0.0.0/0 -d $2 -p udp --dport 514 -j ACCEPT
    sudo ip netns exec $1 iptables -t nat -I POSTROUTING 2 -m ipvs --ipvs -s 0.0.0.0/0 -d $2 -p udp --dport 162 -j ACCEPT
        if [ $? -eq 0 ]; then
          echo "NAT exception successfully added"
        else
          echo "WARNING: Can't add NAT exception."
        fi
  else
    echo "WARNING: Can't add NAT exception. "
  fi
}

function show_nat_exceptions {
  # $1 - namespace id

  sudo ip netns exec $1 iptables -t nat -nvL POSTROUTING --line-numbers > /dev/null
  if [ $? -eq 0 ]; then
    local MATCH=$(sudo ip netns exec $1 iptables -t nat -nvL POSTROUTING --line-numbers | grep "ACCEPT" | wc -l)
    if [ $MATCH -ne 1 ]; then
      local EXCEPTION_RULES=$(sudo ip netns exec $1 iptables -t nat -nvL POSTROUTING --line-numbers | grep "ACCEPT")
      echo "$EXCEPTION_RULES"
    else
      echo "WARNING: no NAT exception rule found."
    fi
  fi
}

function delete_514_nat_exception {
  # $1 - namespace id

  sudo ip netns exec $1 iptables -t nat -nvL POSTROUTING --line-numbers > /dev/null
  if [ $? -eq 0 ]; then
    # check if the rule exists
    local MATCH=$(sudo ip netns exec $1 iptables -t nat -nvL POSTROUTING --line-numbers | grep "udp dpt:514" | wc -l)
    if [ $MATCH -ge 1 ]; then
      # get rules ids and delete them one by one from bottom to top
      local RULES=$(sudo ip netns exec $1 iptables -t nat -nvL POSTROUTING --line-numbers | grep "udp dpt:514" | awk '{print $1}')
      local RSORTED_RULES=$(sort -r <<< "$RULES")
      for rule in $RSORTED_RULES
      do
        sudo ip netns exec $1 iptables -t nat -D POSTROUTING $rule
        if [ $? -eq 0 ]; then
          echo "NAT exception for dst udp 514 successfully deleted, rule num $rule"
        else
          echo "WARNING: Can't delete NAT exception."
        fi
      done
    fi
    local MATCH=$(sudo ip netns exec $1 iptables -t nat -nvL POSTROUTING --line-numbers | grep "udp dpt:162" | wc -l)
    if [ $MATCH -ge 1 ]; then
      # get rules ids and delete them one by one from bottom to top
      local RULES=$(sudo ip netns exec $1 iptables -t nat -nvL POSTROUTING --line-numbers | grep "udp dpt:162" | awk '{print $1}')
      local RSORTED_RULES=$(sort -r <<< "$RULES")
      for rule in $RSORTED_RULES
      do
        sudo ip netns exec $1 iptables -t nat -D POSTROUTING $rule
        if [ $? -eq 0 ]; then
          echo "NAT exception for dst udp 162 successfully deleted, rule num $rule"
        else
          echo "WARNING: Can't delete NAT exception."
        fi
      done
    fi
  fi
}

function check_ingress_interface {
  # $1 - namespace id
  # $2 - network prefix contains eg. 10.0.0., 10.0.2. etc.
  sudo ip netns exec $1 ip a | grep $2 > /dev/null
  if [ $? -eq 0 ]; then
    # count matched interfaces
    local MATCH=$(sudo ip netns exec $1 ip a | grep $2 | wc -l)
    if [ $MATCH -gt 1 ]; then
      echo "WARNING: Multiple ($MATCH) interfaces match prefix $2. Specify more accurate prefix."
    else
      local IFACE=$(sudo ip netns exec $1 ip a | grep $2 | awk '{print $(NF)}')
      echo $IFACE
    fi
  else
    echo "WARNING: Can't find $1 namespace or prefix contains $2 is wrong."
    exit 1
  fi
}

function check_containter {
  # $1 - container name contains eg. msa_sms

  docker ps | grep $1 > /dev/null
  if [ $? -eq 0 ]; then
    local MATCH=$(docker ps | grep $1 | wc -l)
    if [ $MATCH -eq 1 ]; then
      echo "True"
    elif [ $MATCH -eq 0 ]; then
      echo "False"
    else
      echo "Found multiple containers with the same name."
    fi
  fi
}

function check_container_ns {
  # $1 - container name contains eg. msa_sms

  docker ps | grep $1 | awk '{print $1}' > /dev/null
  if [ $? -eq 0 ]; then
    local CONT_ID=$(docker ps | grep $1 | awk '{print $1}')
    docker inspect -f '{{.NetworkSettings.SandboxKey}}' $CONT_ID > /dev/null
    if [ $? -eq 0 ]; then
      local NS_ID_LONG=$(docker inspect -f '{{.NetworkSettings.SandboxKey}}' $CONT_ID)
      local NS_ID_SHORT=$(cut -d'/' -f6 <<< $NS_ID_LONG)
      echo $NS_ID_SHORT
    else
      echo "WARNING: Namespace for $ID container not found. "
    fi
  else
    echo "NOT_FOUND"
  fi
}

function set_rp_filter {
  # https://www.kernel.org/doc/Documentation/networking/ip-sysctl.txt
  # $1 - namespace id
  # $2 - interface name
  # $3 set "2" to loose, set "1" to strict
  sudo ip netns exec $1 sysctl -w net.ipv4.conf.$2.rp_filter=$3 > /dev/null
  if [ $? -eq 0 ]; then
    echo "rp_filter updated for $1 interface $2 namespace"
  else
    echo "WARNING: Can't update rp_filter for $1 interface in $2 namespace."
  fi
}

function show_rp_filter {
  # https://www.kernel.org/doc/Documentation/networking/ip-sysctl.txt
  # $1 - namespace id

  sudo ip netns exec $1 sysctl -a | grep  '\.rp_filter' > /dev/null
  if [ $? -eq 0 ]; then
    sudo ip netns exec $1 sysctl -a | grep '\.rp_filter'
  else
    echo "WARNING: Can't check rp_filter in $2 namespace."
  fi
}

function get_overlay_net_id {
  # $1 - name of the docker network from docker-compose file

  docker network ls | grep $1 | awk '{print $1}' > /dev/null
  if [ $? -eq 0 ]; then
    local NET_ID=$(docker network ls | grep $1 | awk '{print $1}')
    echo $NET_ID
  else
    echo "WARNING: $1 docker network not found."
  fi
}

function get_overlay_net_prefix {
  # $1 - docker network name
  local NET_NAME=$(docker network ls | grep $1 | awk '{print $2}')

  docker inspect -f '{{range .IPAM.Config}}{{println .Subnet}}{{end}}' $NET_NAME > /dev/null
  if [ $? -eq 0 ]; then
    local OVERLAY_NET_PREFIX=$(docker inspect -f '{{range .IPAM.Config}}{{println .Subnet}}{{end}}' $NET_NAME)
    if [[ $OVERLAY_NET_PREFIX =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\/[0-9]+$ ]]; then
      echo $OVERLAY_NET_PREFIX
    else
      echo "WARNING: Can't get docker swarm overlay network prefix."
        fi
  else
    echo "WARNING: Can't get docker swarm overlay network prefix. Can't continue."
  fi
}

function main {

  echo "STEP 1:"
  echo "Creating symlink for netns..."
  create_ns_symlink $RUN_DIR $NETNS_DIR
  echo ""

  echo "STEP 2:"
  echo "Checking <<$INGRESS_NS>> namespace..."
  INGRESS_NS=$(check_ns $NETNS_DIR $INGRESS_NS)
  echo $INGRESS_NS
  echo ""

  echo "STEP 3:"
  echo "Checking docker network <<$DOCKER_NETWORK_2>> namespace..."
  LB_NET_ID=$(get_overlay_net_id $DOCKER_NETWORK_2)
  LB_NS_ID=$(check_lb_ns $NETNS_DIR $LB_NET_ID)
  echo $LB_NS_ID
  echo ""

  echo "STEP 4:"
  echo "Retrieving docker <<$DOCKER_NETWORK_1>> overlay network prefix..."
  OVERLAY_NET_1_PREFIX=$(get_overlay_net_prefix $DOCKER_NETWORK_1)
  echo $OVERLAY_NET_1_PREFIX
  echo ""

  echo "STEP 5:"
  echo "Retrieving docker <<$DOCKER_NETWORK_2>> overlay network prefix..."
  OVERLAY_NET_2_PREFIX=$(get_overlay_net_prefix $DOCKER_NETWORK_2)
  echo $OVERLAY_NET_2_PREFIX
  echo ""

  echo "STEP 6:"
  echo "Checking msa_front is here on this host..."
  MSA_FRONT_HERE=$(check_containter $MSA_FRONT)
  echo $MSA_FRONT_HERE
  echo ""

  echo "STEP 7:"
  echo "Checking msa_sms is here on this host..."
  MSA_SMS_HERE=$(check_containter $MSA_SMS)
  echo $MSA_SMS_HERE
  echo ""

  while getopts "hasd" opt
  do
    case $opt in
      h)
      print_help
      ;;
      a)
      echo "STEP 8:"
      echo "Updating <<$INGRESS_NS>> namespace..."
      echo "---> adding NAT UDP 514 exception... "
      add_514_nat_exception $INGRESS_NS $OVERLAY_NET_1_PREFIX
      echo ""

      echo "STEP 9:"
      echo "Updating load balancer <<$LB_NS_ID>> namespace..."
      echo "---> adding NAT UDP 514 exception... "
      add_514_nat_exception $LB_NS_ID $OVERLAY_NET_2_PREFIX
      echo "---> adding default route... "
      add_default_route $LB_NS_ID
      echo ""

      if [ "$MSA_FRONT_HERE" = "True" ]; then
        echo "STEP 10 (FRONT):"
        echo "Checking <<$MSA_FRONT>> container namespace..."
        MSA_FRONT_NS_ID=$(check_container_ns $MSA_FRONT)
        echo "YES: $MSA_FRONT_NS_ID"
        echo ""

        echo "STEP 11 (FRONT)::"
        echo "Checking ingress <<$MSA_FRONT>> interface..."
        # ${OVERLAY_NET_1_PREFIX::-4} - makes 10.0.0. from 10.0.0.0/24
        MSA_PREFIX=${OVERLAY_NET_1_PREFIX::-4}
        MSA_FRONT_IFACE=$(check_ingress_interface "$MSA_FRONT_NS_ID" "$MSA_PREFIX")
        echo $MSA_FRONT_IFACE
        echo ""

        echo "STEP 12 (FRONT):"
        echo "Updating <<$MSA_FRONT>> rp_filter..."
        set_rp_filter $MSA_FRONT_NS_ID $MSA_FRONT_IFACE 2
        echo ""
      fi

      if [ "$MSA_SMS_HERE" = "True" ]; then
        echo "STEP 10 (SMS):"
        echo "Checking <<$MSA_SMS>> container namespace..."
        MSA_SMS_NS_ID=$(check_container_ns $MSA_SMS)
        echo "YES: $MSA_SMS_NS_ID"
        echo ""

        echo "STEP 11 (SMS):"
        echo "Checking ingress <<$MSA_SMS>> interface..."
        # ${OVERLAY_NET_2_PREFIX::-4} - makes 10.0.2. from 10.0.2.0/24
        MSA_PREFIX=${OVERLAY_NET_2_PREFIX::-4}
        MSA_SMS_IFACE=$(check_ingress_interface "$MSA_SMS_NS_ID" "$MSA_PREFIX")
        echo $MSA_SMS_IFACE
        echo ""

        echo "STEP 12 (SMS):"
        echo "Updating <<$MSA_SMS>> rp_filter..."
        set_rp_filter $MSA_SMS_NS_ID $MSA_SMS_IFACE 2
        echo ""
      fi
      ;;

      s)
      echo "STEP 8:"
      echo "NAT EXCEPTIONS LIST:"
      echo "---> show NAT UDP 514 exceptions in <<$INGRESS_NS>> namespace:"
      show_nat_exceptions $INGRESS_NS
      echo ""
      echo "---> show NAT UDP 514 exceptions in <<$LB_NS_ID>> namespace:"
      show_nat_exceptions $LB_NS_ID
      echo ""

      if [ "$MSA_FRONT_HERE" = "True" ]; then
        echo "STEP 9 (FRONT):"
        echo "Checking <<$MSA_FRONT>> container namespace..."
        MSA_FRONT_NS_ID=$(check_container_ns $MSA_FRONT)
        echo "YES: $MSA_FRONT_NS_ID"
        echo ""

        echo "STEP 10 (FRONT):"
        echo "Checking <<$MSA_FRONT>> rp_filter..."
        show_rp_filter $MSA_FRONT_NS_ID
        echo ""

        echo "STEP 11 (FRONT):"
        echo "Checking ingress <<$MSA_FRONT>> interface..."
        # ${OVERLAY_NET_1_PREFIX::-4} - makes 10.0.0. from 10.0.0.0/24
        MSA_PREFIX=${OVERLAY_NET_1_PREFIX::-4}
        MSA_FRONT_IFACE=$(check_ingress_interface "$MSA_FRONT_NS_ID" "$MSA_PREFIX")
        echo $MSA_FRONT_IFACE
        echo ""
      fi

      if [ "$MSA_SMS_HERE" = "True" ]; then
        echo "STEP 9 (SMS):"
        echo "Checking <<$MSA_SMS>> container namespace..."
        MSA_SMS_NS_ID=$(check_container_ns $MSA_SMS)
        echo "YES: $MSA_SMS_NS_ID"
        echo ""

        echo "STEP 10 (SMS):"
        echo "Checking <<$MSA_SMS>> rp_filter..."
        show_rp_filter $MSA_SMS_NS_ID
        echo ""

        echo "STEP 11 (SMS):"
        echo "Checking ingress <<$MSA_SMS>> interface..."
        # ${OVERLAY_NET_2_PREFIX::-4} - makes 10.0.2. from 10.0.2.0/24
        MSA_PREFIX=${OVERLAY_NET_2_PREFIX::-4}
        MSA_SMS_IFACE=$(check_ingress_interface "$MSA_SMS_NS_ID" "$MSA_PREFIX")
        echo $MSA_SMS_IFACE
        echo ""
      fi
      ;;

      d)
      echo "STEP 8:"
      echo "Removing NAT UDP 514 exceptions in <<$INGRESS_NS>> namespace..."
      delete_514_nat_exception $INGRESS_NS
      echo "Removing NAT UDP 514 exceptions in <<$LB_NS_ID>> namespace..."
      delete_514_nat_exception $LB_NS_ID
      echo ""

      if [ "$MSA_FRONT_HERE" = "True" ]; then
        echo "STEP 9 (FRONT):"
        echo "Checking <<$MSA_FRONT>> container namespace..."
        MSA_FRONT_NS_ID=$(check_container_ns $MSA_FRONT)
        echo "YES: $MSA_FRONT_NS_ID"
        echo ""

        echo "STEP 10 (FRONT):"
        echo "Checking ingress <<$MSA_FRONT>> interface..."
        # ${OVERLAY_NET_1_PREFIX::-4} - makes 10.0.0. from 10.0.0.0/24
        MSA_PREFIX=${OVERLAY_NET_1_PREFIX::-4}
        MSA_FRONT_IFACE=$(check_ingress_interface "$MSA_FRONT_NS_ID" "$MSA_PREFIX")
        echo $MSA_FRONT_IFACE
        echo ""

        echo "STEP 11 (FRONT):"
        echo "Updating <<$MSA_FRONT>> rp_filter..."
        set_rp_filter $MSA_FRONT_NS_ID $MSA_FRONT_IFACE 1
        echo ""
      fi

      if [ "$MSA_SMS_HERE" = "True" ]; then
        echo "STEP 9 (SMS):"
        echo "Checking <<$MSA_SMS>> container namespace..."
        MSA_SMS_NS_ID=$(check_container_ns $MSA_SMS)
        echo "YES: $MSA_SMS_NS_ID"
        echo ""

        echo "STEP 10 (SMS):"
        echo "Checking ingress <<$MSA_SMS>> interface..."
        # ${OVERLAY_NET_2_PREFIX::-4} - makes 10.0.2. from 10.0.2.0/24
        MSA_PREFIX=${OVERLAY_NET_2_PREFIX::-4}
        MSA_SMS_IFACE=$(check_ingress_interface "$MSA_SMS_NS_ID" "$MSA_PREFIX")
        echo $MSA_SMS_IFACE
        echo ""

        echo "STEP 11 (SMS):"
        echo "Updating <<$MSA_SMS>> rp_filter..."
        set_rp_filter $MSA_SMS_NS_ID $MSA_SMS_IFACE 1
        echo ""
      fi
      ;;

      *)
      echo "Invalid option"
      print_help
      ;;
    esac
  done

  echo "Completed successfully."
}

main "$@"
