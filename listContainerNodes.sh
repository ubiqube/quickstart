#!/bin/bash
# for node in V01MANOUBSW01-BR1707BRF V02MANOUBSW02-BR1807BRF V03MANOUBSW03-BR1907BRF V01MANOUBDB01-BR1707BRF V02MANOUBDB02-BR1807BRF;
 for node in V01MANOUBSW01-AI1601KVDC V02MANOUBSW02-AI1701KVDC V03MANOUBSW03-AI1801KVDC V01MANOUBDB01-AI1601KVDC V02MANOUBDB02-AI1701KVDC;

 do 
	 echo "#################### $node #######################";
	 ssh $node "docker ps";
	 echo;
 done

