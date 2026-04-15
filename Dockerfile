FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y openssh-server sudo curl wget git python3 python3-pip build-essential net-tools iputils-ping tree htop && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd && echo 'PermitRootLogin no' >> /etc/ssh/sshd_config && echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config

RUN mkdir -p /shared && chmod 1777 /shared && mkdir -p /var/log/audit && chmod 777 /var/log/audit

COPY signup.sh /usr/local/bin/signup.sh
COPY login-wrapper.sh /usr/local/bin/login-wrapper.sh
RUN chmod +x /usr/local/bin/signup.sh /usr/local/bin/login-wrapper.sh

RUN echo 'ForceCommand /usr/local/bin/login-wrapper.sh' >> /etc/ssh/sshd_config

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]