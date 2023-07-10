#!/bin/bash
 for node in 127.0.0.1 mano1 mano2 mano3 mano4 mano5 mano6 mano7 mano8;do echo "#################### $node #######################";ssh $node "docker ps";echo;done

