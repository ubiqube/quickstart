Quickstart
------------------------------------

This quickstart project will get you started with the MSActivator(TM)(MSA) orchestration tool.


# Setting up the tutorial
To quickly get started with MSA, use Docker Compose to set up an environment to host the MSA server and some entities to be managed. 

Before starting this tutorial, first install [Docker](https://docs.docker.com/install/) on your machine. Next install [Docker Compose](https://docs.docker.com/compose/install/) on your machine.

1. check your dockerhub account password - or create a new account
2. ask for access to private repo: `ubiqube/msa2`
3. check your docker engine has access to dockerhub
4. clone this repo: `git clone https://github.com/ubiqube/quickstart.git`
5. run: `docker login`
6. run: `docker-compose -f docker-compose.yml -f lab/docker-compose.lab.yml up -d `
7. browse: https://localhost/

Docker Compose will set up the MSA orchestration platform as well as 1 VM like, Linux Centos 6.8 based container to experiement on (this container is defined in lab/linux.me/Dockerfile in this quickstart repository).  

When Docker Compose is done deploying and the MSA orchestration platform is running, you will be able to open the dashboard at https://127.0.0.1. 

When you see the following output, the MSA is ready to be used

```
Creating quickstart_ui_1      ... done
Creating quickstart_db_1      ... done
Creating quickstart_es_1      ... done
Creating quickstart_me_1      ... done
Creating quickstart_camunda_1 ... done
Creating quickstart_kibana_1  ... done
Creating quickstart_api_1     ... done
Creating quickstart_front_1   ... done
```

If you get a gateway error, the web server is probably still starting and you may have to wait for 10-20 more seconds before trying again.

To get an interactive shell on the MSA main container (this will ne needed later)
```
docker exec -it "inmanta_quickstart_server" bash
```

# Breaking down/Resetting the quickstart environment
To fully clean up or reset the environment, run the following commands:

1. `docker-compose -f docker-compose.yml -f lab/docker-compose.lab.yml down`
2. `docker volume prune -f`
3. `docker ps -a | grep "quickstart" | awk '{print $3}' | xargs docker rmi`

This will give you a clean environment next time you run docker-compose up.

NOTE: To get the access to the UBiqube dockerhub private repository please contact us ...

Requirements on the host machine
--------------------------------

The host machine should have hardware specs similar to that
of the VM running the .ova flavour of MSA:

- 8Go, 2CPU, 50Go
