#!/bin/bash
 for node in V01MANOUBSW01-BR1707BRF V02MANOUBSW02-BR1807BRF V03MANOUBSW03-BR1907BRF V01MANOUBDB01-BR1707BRF V02MANOUBDB02-BR1807BRF;
 do 
	 echo "#################### $node #######################";
	 ssh $node "docker ps";
	 echo;
 done

