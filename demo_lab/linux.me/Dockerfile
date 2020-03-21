FROM centos:6.8

# for msa asset info
RUN yum install -y redhat-lsb-core

# for msa asset access
RUN yum install -y openssh-server sudo
RUN useradd msa
RUN passwd --stdin msa <<< "ubiqube"


CMD [ "/sbin/init" ]
