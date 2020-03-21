Quickstart
------------------------------------

This quickstart project will get you started with the MSActivator orchestration tool.


Setting up the tutorial
To quickly get started with MSA, use Docker Compose to set up an environment to host the Inmanta server and some machines to be managed. Before starting this tutorial, first install Docker on your machine. Next install Docker Compose on your machine.


1. check your dockerhub account password - or create a new account
2. ask for access to private repo: `ubiqube/msa2`
3. check your docker engine has access to dockerhub
4. clone this repo: `git clone git@github.com:ubiqube/quickstart.git`
5. run: `docker login`
6. run: `docker-compose -f docker-compose.yml -f demo_lab/docker-compose.lab.yml up -d `
7. browse: https://localhost/


Requirements on the host machine
--------------------------------

The host machine should have hardware specs similar to that
of the VM running the .ova flavour of MSA:

- 16Go, 4CPU, 100Go


Linux (or Linux VM) docker engine
---------------------------------

	sudo sysctl -w vm.max_map_count=262144
	sudo tee -a /etc/sysctl.conf <<< "vm.max_map_count=262144"


MacOS docker engine
-------------------

	TODO: document if/howto set vm.max_map_count=262144


Windows docker engine
---------------------

	docker-machine create -d virtualbox  \
		--virtualbox-cpu-count=2 \
		--virtualbox-memory=8192 \
		--virtualbox-disk-size=50000 \
		default


In the docker VM, do as for Linux host above:

	sudo sysctl -w vm.max_map_count=262144
	sudo tee -a /etc/sysctl.conf <<< "vm.max_map_count=262144"


The docker VM is mapped to a local IP on the Windows host,
access to the msa is _NOT_ done via `https://localhost`,
you must lookup the IP with:

```
$ docker-machine ls
NAME      ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER     ERRORS
default   *        virtualbox   Running   tcp://192.168.99.100:2376           v19.03.5
```

