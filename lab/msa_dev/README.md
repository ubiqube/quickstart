
# Linuxdev

## Generate image

* First commit your changes because the commit ID of the changes will be used
  as tag for the image
* Run: `docker build -t ubiqube/msa2-linuxdev:$(git rev-parse HEAD) .`
* Push image: `docker push ubiqube/msa2-linuxdev:$(git rev-parse HEAD)`
* update the PR with new tag in docker-compose files, for new images created and pushed

## Exporting home

Exporting home allow you to keep your settings accross containers updates. On first initialization home will be filled with traditional `.bashrc` and other files.

You have to create a directory `home` with the correct rights on it, let's assume for the folling documentation that this home is inside the `msa-docker` repository.

```bash
mkdir home
chmod 700 home
chown 1000:1000 home
```

### Using docker run

```bash
docker run -it -p 2223:22 --rm --name linuxdev -v ./home/:/home/ncuser/
```

### Using docker-compose.override.yml

```yaml
version: "3.8"
services:
  msa-dev:
    volumes:
      - ./home/:/home/ncuser/
```

## Using ssh key

SSH server is enable in this container. To use this feature you can give your public key using a volume

### Using docker run

```bash
docker run -it -p 2223:22 --rm --name linuxdev -v ~/.ssh/authorized_keys:/home/ncuser/.ssh/authorized_keys linuxdev
```

Another alternative is to export home globally.

```bash
docker run -it -p 2223:22 --rm --name linuxdev -v ~/.ssh/authorized_keys:/home/ncuser/.ssh/authorized_keys linuxdev
```

### Using docker-compose.override.yml

```yaml
version: "3.8"
services:
  msa-dev:
    volumes:
      - ~/.ssh/authorized_keys:/home/ncuser/.ssh/authorized_keys
```

## Tools

There is a few tools that you can used.

### install_libraries.sh

This script will allow you to install all needed modules on first installation, but also help you to switch between various version, or keeping your repositories uptodate.

If called when no the repository is not present and with no branch / tag the default branch `master` will be used. Otherwise the tag/branch will be fetch.

If repository exist, the default behavior for this tool is just to pull the source code in each repository, with out taking care of the actual branch/tag.

#### Switching to a given tag

Switch to a given tag can be achieved using `-t my_tag` where `my_tag` is an already existing tag. You can switch to an upper version and then rolback to an older one, all correct dependencies will be installed.

When switching to a new tag a branch with the same name will be created. This mean that switching to another branch require importing the changeset from the older branch.

#### Switching to a given branch

Switch to a given branch can be achieved using `-b my_branch` where `my_branch` is an already existing branch. All dependencies of your branch will be installed after the switch.

All other subsequent invocation of the script with no parameters will do a `git pull` and dependencies installation.

### install_repository.sh

This simple script help to install a git workflow repository in `/opt/fmc_repository`, and install the workflow dependencies if needed.

Clone the repository in `/opt/fmc_repository/etsi-mano-workflows` and create a link `/opt/fmc_repository/Process/etsi-mano-workflows`

```bash
install_repository.sh https://github.com/openmsa/etsi-mano-workflows.git
```

Clone the repository in `/opt/fmc_repository/ETSI` and create a link `/opt/fmc_repository/Process/ETSI`

```bash
install_repository.sh https://github.com/openmsa/etsi-mano-workflows.git ETSI
```

### install_repo_deps.sh

Simple script to deploy workflow dependencies.

This script will call successively `install.sh` then `requirements.txt` then `setup.py`.

The idea is to install every things under `/opt/fmc_repository` or any other volumes.

Python library must be installed in `/opt/fmc_repository/Process/PythonReference/`

Binary dependencies must be installed in `/opt/fmc_repository/Process/PythonReference/bin`
