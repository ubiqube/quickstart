FROM centos:7

RUN groupadd -r ncuser -g 1000 && useradd -r -u 1000 -g ncuser -m -c "ncuser" ncuser

RUN yum -y install https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm git php openssh-server sudo iproute nano
RUN yum -y upgrade git 

RUN git config --global alias.lg "log --graph --pretty=format:'%C(red)%h%C(reset) -%C(yellow)%d%C(reset) %s %C(bold blue)<%an>%C(reset) %C(green)(%ar)%C(reset)' --abbrev-commit --date=relative"; \
    git config --global push.default simple; \
    :

COPY resources/scripts/create_test_me.sh /usr/bin/
COPY resources/scripts/create_mini_lab.sh /usr/bin/
COPY resources/scripts/install_libraries.sh /usr/bin/
COPY resources/scripts/install_license.sh /usr/bin/
COPY resources/scripts/wait_for_api.sh /usr/bin/

RUN chmod a+x /usr/bin/create_mini_lab.sh; \
    chmod a+x /usr/bin/install_libraries.sh; \
    chmod a+x /usr/bin/create_test_me.sh; \
    chmod a+x /usr/bin/install_license.sh; \
    chmod a+x /usr/bin/wait_for_api.sh; \
    :

CMD [ "/sbin/init" ]