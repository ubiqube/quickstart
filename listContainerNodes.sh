#!/bin/bash
 for node in V01MANOUBSW01 V02MANOUBSW02 V03MANOUBSW03 V01MANOUBDB01 V02MANOUBDB02 V03MANOUBDB03;

 do 
	 echo "#################### $node #######################";
	 ssh $node "docker ps";
	 echo;
 done

