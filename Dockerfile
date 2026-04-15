FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y openssh-server sudo curl wget git python3 python3-pip build-essential net-tools iputils-ping tree htop && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd
RUN echo 'PermitRootLogin no' >> /etc/ssh/sshd_config
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config

RUN useradd -m -s /bin/bash intern1 && echo 'intern1:intern123' | chpasswd
RUN useradd -m -s /bin/bash intern2 && echo 'intern2:intern123' | chpasswd
RUN useradd -m -s /bin/bash intern3 && echo 'intern3:intern123' | chpasswd

RUN mkdir -p /shared && chmod 1777 /shared
RUN mkdir -p /var/log/audit && chmod 777 /var/log/audit

COPY audit-logger.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/audit-logger.sh

RUN echo 'session optional pam_exec.so /usr/local/bin/audit-logger.sh' >> /etc/pam.d/sshd

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]