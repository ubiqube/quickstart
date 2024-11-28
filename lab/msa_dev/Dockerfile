FROM docker.io/ubiqube/ubi-almalinux9:latest
ARG SSH_USER_PATH=/home/ncuser
ARG SSH_USER_TOTO=/home/toto

COPY resources/.gitconfig /etc/skel/
RUN install -c -o root -g wheel -D -m 600 /dev/null /etc/skel/.ssh/authorized_keys

RUN groupadd -r ncuser -g 1000 && useradd -r -u 1000 -g ncuser -m -c "ncuser" ncuser

# https://packages.endpointdev.com/rhel/9/main/x86_64/endpoint-repo.noarch.rpm
RUN yum -y install \
    php-cli openssh-server git sudo iproute nano wget unzip coreutils-common \
    python3.12 python3.12-pip python3.12-setuptools bash-completion php-json && \
    yum -y upgrade git && \
    yum update -y && \
    yum clean all && \
    rm -rf /var/cache/yum

COPY --chmod=755 resources/scripts/*.sh /usr/bin/

RUN mkdir /opt/ubiqube /opt/fmc_repository /opt/fmc_entities && \
    chown ncuser:ncuser /opt/ubiqube /opt/fmc_repository /opt/fmc_entities && \
    mkdir /opt/devops && \
    chown ncuser:ncuser /opt/devops

COPY resources/opt/fmc_repository/ /usr/share/install-libraries/meta/
COPY resources/il-lib.sh /usr/share/install-libraries/
COPY --chmod=0600 resources/sshd/* /etc/ssh/
COPY resources/sudoers/ncuser /etc/sudoers.d/
COPY docker-entrypoint.sh /
EXPOSE 22

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.12 20 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 20 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3.12 20 && \
    update-alternatives --install /usr/bin/pip3 pip3 /usr/bin/pip3.12 20 && \
    update-alternatives --set python /usr/bin/python3.12 && \
    update-alternatives --set python3 /usr/bin/python3.12 && \
    update-alternatives --set pip /usr/bin/pip3.12 && \
    update-alternatives --set pip3 /usr/bin/pip3.12

USER ncuser
ENV PYTHONPATH /opt/fmc_repository/Process/PythonReference/
ENV PATH $PYTHONPATH/bin:$PATH

CMD [ "/docker-entrypoint.sh" ]
