Quickstart
------------------------------------

This quickstart project will get you started with the MSActivator orchestration tool.


# Setting up the tutorial
To quickly get started with MSA, use Docker Compose to set up an environment to host the MSA server and some entities to be managed. 

Before starting this tutorial, first install [Docker](https://docs.docker.com/install/) on your machine. Next install [Docker Compose](https://docs.docker.com/compose/install/) on your machine.

1. check your dockerhub account password - or create a new account
2. ask for access to private repo: `ubiqube/msa2`
3. check your docker engine has access to dockerhub
4. clone this repo: `git clone git@github.com:ubiqube/quickstart.git`
5. run: `docker login`
6. run: `docker-compose -f docker-compose.yml -f lab/docker-compose.lab.yml up -d `
7. browse: https://localhost/

To get the access to the UBiqube dockerhub private repository please contact us ...

Requirements on the host machine
--------------------------------

The host machine should have hardware specs similar to that
of the VM running the .ova flavour of MSA:

- 8Go, 2CPU, 50Go
