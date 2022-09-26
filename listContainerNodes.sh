#!/bin/bash
 for node in V01MANOUBSW01-AI1601KVDC V02MANOUBSW02-AI1701KVDC V03MANOUBSW03-AI1801KVDC V01MANOUBDB01-AI1601KVDC V02MANOUBDB02-AI1701KVDC;do echo "#################### $node #######################";ssh $node "docker ps";echo;done

