#!/usr/bin/env bash

set -e
unset NET_ID
unset OVERLAY_NET_PREFIX
unset MATCH
unset NS_ID
unset RSORTED_RULES
unset RUN_DIR
unset NETNS_DIR
unset DOCKER_NETWORK
unset IP_PREFIX
unset rule
unset BACKUP_FILE
unset EXCEPTION_PREFIX

RUN_DIR="/var/run"
NETNS_DIR="/var/run/docker/netns"
DOCKER_NETWORK="ha_default"


function print_help {
echo "###################################################################"
echo "###################################################################"
echo "###################################################################"
echo "###################################################################"
echo ""
echo "Script to update docker swarm network configuration"
echo ""
echo "Options:"
echo "[-x]"
echo "adds sNAT exception in ha_default network namespace"
echo "example: ./script.sh -x 1.2.3.4/32"
echo "example: ./script.sh -x 1.2.3.4"
echo "example: ./script.sh -x 10.1.1.0/24"
echo "[-s]"
echo "saves iptables rules for ha_default network namespace"
echo "example: ./script.sh -s ./iptables_backup_file"
echo "[-r]"
echo "restores iptables rules for ha_default network namespace"
echo "example: ./script.sh -r ./iptables_backup_file"
echo "[-n]"
echo "shows nat exceptions"
echo "example: ./script.sh -n"
echo "[-d]"
echo "deletes nat exception for certain ip prefix"
echo "example: ./script.sh -d 1.2.3.4"
echo "example: ./script.sh -d 1.2.3.4/32"
echo "[-g]"
echo "adds default route for ha_default network namespace"
echo "example: ./script.sh -g"
echo "[-p]"
echo "adds nat exception for 0.0.0.0/0 source and udp 514 destinnation"
echo "example: ./script.sh -p"
echo "[-q]"
echo "removes nat exception for 0.0.0.0/0 source and udp 514 destinnation"
echo "example: ./script.sh -g"
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

  if [ -d "$1" ] && [ -d "$2" ]; then
    cd "$1"
    ln -sfn "$2" netns
        if [ $? -eq 0 ]; then
          echo "Symlink successfully created"
        else
          echo "Error: Can't create symlink. Can't continue."
          exit 1
        fi
    cd -
  else
    echo "Error: $1 or $2 not found. Can't continue."
    exit 1
  fi
}

function get_overlay_net_id {
  # $1 - name of the docker network from docker-compose file

  docker network ls | grep $1 | awk '{print $1}' > /dev/null
  if [ $? -eq 0 ]; then
    local NET_ID=$(docker network ls | grep $DOCKER_NETWORK | awk '{print $1}')
    echo $NET_ID
  else
    echo "Error: ${DOCKER_NETWORK} docker network not found. Can't continue."
    exit 1
  fi
}

function get_overlay_net_prefix {
  # $1 - docker network id

  docker inspect -f '{{range .IPAM.Config}}{{println .Subnet}}{{end}}' $1 > /dev/null
  if [ $? -eq 0 ]; then
    local OVERLAY_NET_PREFIX=$(docker inspect -f '{{range .IPAM.Config}}{{println .Subnet}}{{end}}' $1)
    if [[ $OVERLAY_NET_PREFIX =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\/[0-9]+$ ]]; then
      echo $OVERLAY_NET_PREFIX
    else
      echo "Error: Can't get docker swarm overlay network prefix. Can't continue."
      exit 1
        fi
  else
    echo "Error: Can't get docker swarm overlay network prefix. Can't continue."
    exit 1
  fi
}

function check_ns {
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
      echo "Error: $1 namespace not found. Can't continue."
          exit 1
    fi
  else
    echo "Error: $1 directory not found. Can't continue."
    exit 1
  fi
}

function add_default_route {
  # $1 - namespace id

  ip netns exec $1 ip r > /dev/null
  if [ $? -eq 0 ]; then
    local MATCH=$(ip netns exec $1 ip r | grep default | wc -l)
      if [ $MATCH -eq 1 ]; then
        echo "Default route already exists"
      else
        ip netns exec $1 ip r a default dev eth0
        if [ $? -eq 0 ]; then
          echo "Default rule successfully added."
        else
          "Error: Can't add default route to $1 namespace. Can't continue."
        fi
      fi
  else
    echo "Error: Can't add default route to $1 namespace. Can't continue."
    exit 1
  fi
}

function add_nat_exception {
  # $1 - namespace id
  # $2 - ip nat to except
  # $3 - destinnation ip prefix

  # add /32 if missed
  if [[ $2 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\/[0-9]+$ ]]; then
    local IP_PREFIX=$2
  elif [[ $2 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    local IP_PREFIX="$2/32"
  else
    echo "Wrong $IP_PREFIX format. Can't continue."
    exit 1
  fi

  ip netns exec $1 iptables -t nat -nvL POSTROUTING --line-numbers > /dev/null
  if [ $? -eq 0 ]; then
    ip netns exec $1 iptables -t nat -I POSTROUTING 2 -m ipvs --ipvs -s $IP_PREFIX -d $3 -j ACCEPT
        if [ $? -eq 0 ]; then
          echo "NAT exception successfully added"
        else
          echo "Error: Can't add NAT exception. Can't continue."
          exit 1
        fi
  else
    echo "Error: Can't add NAT exception. Can't continue."
    exit 1
  fi
}

function add_514_nat_exception {
  # $1 - namespace id
  # $2 - destinnation ip prefix

  ip netns exec $1 iptables -t nat -nvL POSTROUTING --line-numbers > /dev/null
  if [ $? -eq 0 ]; then
    ip netns exec $1 iptables -t nat -I POSTROUTING 2 -m ipvs --ipvs -s 0.0.0.0/0 -d $2 -p udp --dport 514 -j ACCEPT
        if [ $? -eq 0 ]; then
          echo "NAT exception successfully added"
        else
          echo "Error: Can't add NAT exception. Can't continue."
          exit 1
        fi
  else
    echo "Error: Can't add NAT exception. Can't continue."
    exit 1
  fi
}

function show_nat_exceptions {
  # $1 - namespace id

  ip netns exec $1 iptables -t nat -nvL POSTROUTING --line-numbers > /dev/null
  if [ $? -eq 0 ]; then
    local MATCH=$(ip netns exec $1 iptables -t nat -nvL POSTROUTING --line-numbers | grep "ACCEPT" | wc -l)
    if [ $MATCH -ne 1 ]; then
      local EXCEPTION_RULES=$(ip netns exec $1 iptables -t nat -nvL POSTROUTING --line-numbers | grep "ACCEPT")
      echo "$EXCEPTION_RULES"
    else
      echo "No exception rules found."
    fi
  fi
}

function delete_nat_exception {
  # $1 - namespace id
  # $2 - ip to nat except

  # strip /32 to match iptables format
  if [[ $2 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\/[0-9]+$ ]]; then
    local IP_PREFIX=$( cut -d '/' -f 1 <<< "$2" )
  elif [[ $2 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    local IP_PREFIX=$2
  else
    echo "Wrong prefix=$2 format. Can't continue."
    exit 1
  fi

  ip netns exec $1 iptables -t nat -nvL POSTROUTING --line-numbers > /dev/null
  if [ $? -eq 0 ]; then
    # check if the rule exists
    local MATCH=$(ip netns exec $1 iptables -t nat -nvL POSTROUTING --line-numbers | grep "$IP_PREFIX" | wc -l)
    if [ $MATCH -ge 1 ]; then
      # get rules ids and delete them one by one from bottom to top
      local RULES=$(ip netns exec $1 iptables -t nat -nvL POSTROUTING --line-numbers | grep "$IP_PREFIX" | awk '{print $1}')
      local RSORTED_RULES=$(sort -r <<< "$RULES")
      for rule in $RSORTED_RULES
      do
        ip netns exec $1 iptables -t nat -D POSTROUTING $rule
        if [ $? -eq 0 ]; then
          echo "NAT exception for $2 successfully deleted, rule num $rule"
        else
          echo "Error: Can't delete NAT exception. Can't continue."
          exit 1
        fi
      done
    fi
  fi
}

function delete_514_nat_exception {
  # $1 - namespace id

  ip netns exec $1 iptables -t nat -nvL POSTROUTING --line-numbers > /dev/null
  if [ $? -eq 0 ]; then
    # check if the rule exists
    local MATCH=$(ip netns exec $1 iptables -t nat -nvL POSTROUTING --line-numbers | grep "udp dpt:514" | wc -l)
    if [ $MATCH -ge 1 ]; then
      # get rules ids and delete them one by one from bottom to top
      local RULES=$(ip netns exec $1 iptables -t nat -nvL POSTROUTING --line-numbers | grep "udp dpt:514" | awk '{print $1}')
      local RSORTED_RULES=$(sort -r <<< "$RULES")
      for rule in $RSORTED_RULES
      do
        ip netns exec $1 iptables -t nat -D POSTROUTING $rule
        if [ $? -eq 0 ]; then
          echo "NAT exception for dst udp 514 successfully deleted, rule num $rule"
        else
          echo "Error: Can't delete NAT exception. Can't continue."
          exit 1
        fi
      done
    fi
  fi
}

function save_iptables {
  # $1 - namespace id
  # $2 - iptables backup file

  ip netns exec $1 iptables-save > $2
  if [ $? -eq 0 ]; then
    echo "iptables rules at $1 namespace saved to $2 file"
  else
    echo "Error: Can't save iptables rules. Can't continue."
    exit 1
  fi
}

function restore_iptables {
  # $1 - namespace id
  # $2 - iptables backup file

  ip netns exec $1 iptables-restore < $2
  if [ $? -eq 0 ]; then
    echo "iptables rules at $1 namespace restored from $2 file"
  else
    echo "Error: Can't save iptables rules. Can't continue."
    exit 1
  fi
}

function main {

  while getopts "x:d:s:r:nhgpq" opt
  do
    case $opt in
      h)
      print_help
      ;;

      p)
      echo "Creating symlink for netns..."
      create_ns_symlink $RUN_DIR $NETNS_DIR
      echo "Retrieving docker overlay netwrok id..."
      NET_ID=$(get_overlay_net_id $DOCKER_NETWORK)
      echo $NET_ID
      echo "Retrieving docker swarm overlay network prefix..."
      OVERLAY_NET_PREFIX=$(get_overlay_net_prefix $DOCKER_NETWORK)
      echo $OVERLAY_NET_PREFIX
      echo "Checking correlated namespace..."
      NS_ID=$(check_ns $NETNS_DIR $NET_ID)
      echo $NS_ID
      echo "Adding default route to the namespace..."
      add_default_route $NS_ID
      echo "Adding NAT UDP 514 exception to the namespace..."
      add_514_nat_exception $NS_ID $OVERLAY_NET_PREFIX
      ;;

      q)
      echo "Creating symlink for netns..."
      create_ns_symlink $RUN_DIR $NETNS_DIR
      echo "Retrieving docker overlay netwrok id..."
      NET_ID=$(get_overlay_net_id $DOCKER_NETWORK)
      echo $NET_ID
      echo "Checking correlated namespace..."
      NS_ID=$(check_ns $NETNS_DIR $NET_ID)
      echo $NS_ID
      echo "Deleting NAT UDP 514 exception from the namespace..."
      delete_514_nat_exception $NS_ID
      ;;

      g)
      echo "Creating symlink for netns..."
      create_ns_symlink $RUN_DIR $NETNS_DIR
      echo "Retrieving docker overlay netwrok id..."
      NET_ID=$(get_overlay_net_id $DOCKER_NETWORK)
      echo $NET_ID
      echo "Retrieving docker swarm overlay network prefix..."
      OVERLAY_NET_PREFIX=$(get_overlay_net_prefix $DOCKER_NETWORK)
      echo $OVERLAY_NET_PREFIX
      echo "Checking correlated namespace..."
      NS_ID=$(check_ns $NETNS_DIR $NET_ID)
      echo $NS_ID
      echo "Adding default route to the namespace..."
      add_default_route $NS_ID
      ;;

      n)
      echo "Creating symlink for netns..."
      create_ns_symlink $RUN_DIR $NETNS_DIR
      echo "Retrieving docker overlay netwrok id..."
      NET_ID=$(get_overlay_net_id $DOCKER_NETWORK)
      echo $NET_ID
      echo "Retrieving docker swarm overlay network prefix..."
      OVERLAY_NET_PREFIX=$(get_overlay_net_prefix $DOCKER_NETWORK)
      echo $OVERLAY_NET_PREFIX
      echo "Checking correlated namespace..."
      NS_ID=$(check_ns $NETNS_DIR $NET_ID)
      echo $NS_ID
      show_nat_exceptions $NS_ID
      ;;

      x)
      EXCEPTION_PREFIX=${OPTARG}
      echo "Creating symlink for netns..."
      create_ns_symlink $RUN_DIR $NETNS_DIR
      echo "Retrieving docker overlay netwrok id..."
      NET_ID=$(get_overlay_net_id $DOCKER_NETWORK)
      echo $NET_ID
      echo "Retrieving docker swarm overlay network prefix..."
      OVERLAY_NET_PREFIX=$(get_overlay_net_prefix $DOCKER_NETWORK)
      echo $OVERLAY_NET_PREFIX
      echo "Checking correlated namespace..."
      NS_ID=$(check_ns $NETNS_DIR $NET_ID)
      echo $NS_ID
      echo "Adding default route to the namespace..."
      add_default_route $NS_ID
      echo "Adding NAT exception to the namespace..."
      add_nat_exception $NS_ID $EXCEPTION_PREFIX $OVERLAY_NET_PREFIX
      ;;

      d)
      EXCEPTION_PREFIX=${OPTARG}
      echo "Creating symlink for netns..."
      create_ns_symlink $RUN_DIR $NETNS_DIR
      echo "Retrieving docker overlay netwrok id..."
      NET_ID=$(get_overlay_net_id $DOCKER_NETWORK)
      echo $NET_ID
      echo "Checking correlated namespace..."
      NS_ID=$(check_ns $NETNS_DIR $NET_ID)
      echo $NS_ID
      echo "Deleting NAT exception from the namespace..."
      delete_nat_exception $NS_ID $EXCEPTION_PREFIX
      ;;

      s)
      BACKUP_FILE=${OPTARG}
      echo "Creating symlink for netns..."
      create_ns_symlink $RUN_DIR $NETNS_DIR
      echo "Retrieving docker overlay netwrok id..."
      NET_ID=$(get_overlay_net_id $DOCKER_NETWORK)
      echo $NET_ID
      echo "Checking correlated namespace..."
      NS_ID=$(check_ns $NETNS_DIR $NET_ID)
      echo $NS_ID
      echo "Saving iptables rules..."
      save_iptables $NS_ID $BACKUP_FILE
      ;;

      r)
      BACKUP_FILE=${OPTARG}
      echo "Creating symlink for netns..."
      create_ns_symlink $RUN_DIR $NETNS_DIR
      echo "Retrieving docker overlay netwrok id..."
      NET_ID=$(get_overlay_net_id $DOCKER_NETWORK)
      echo $NET_ID
      echo "Checking correlated namespace..."
      NS_ID=$(check_ns $NETNS_DIR $NET_ID)
      echo $NS_ID
      echo "Adding default route to the namespace..."
      add_default_route $NS_ID
      echo "Restoring iptables rules..."
      restore_iptables $NS_ID $BACKUP_FILE
      ;;

      *)
      echo "Invalid option"
      print_help
      ;;
    esac
  done
}

main "$@"
