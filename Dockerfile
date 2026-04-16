FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server sudo curl wget git \
    python3 python3-pip build-essential \
    net-tools iputils-ping tree htop \
    shellinabox uuid-runtime \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd
# SSH settings
RUN echo 'PermitRootLogin no' >> /etc/ssh/sshd_config
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
RUN echo 'ForceCommand /usr/local/bin/session-wrapper.sh' >> /etc/ssh/sshd_config
RUN echo 'AllowUsers intern1 intern2 intern3' >> /etc/ssh/sshd_config
RUN echo 'AllowTcpForwarding no' >> /etc/ssh/sshd_config
RUN echo 'X11Forwarding no' >> /etc/ssh/sshd_config
RUN echo 'PermitTunnel no' >> /etc/ssh/sshd_config

RUN useradd -m -s /bin/bash intern1 && echo 'intern1:intern123' | chpasswd
RUN useradd -m -s /bin/bash intern2 && echo 'intern2:intern123' | chpasswd
RUN useradd -m -s /bin/bash intern3 && echo 'intern3:intern123' | chpasswd

RUN mkdir -p /shared && chmod 1777 /shared
RUN mkdir -p /var/log/audit && chmod 777 /var/log/audit

COPY scripts/audit-logger.sh      /usr/local/bin/audit-logger.sh
COPY scripts/session-wrapper.sh   /usr/local/bin/session-wrapper.sh
COPY scripts/entrypoint.sh        /usr/local/bin/entrypoint.sh
 
RUN chmod +x \
    /usr/local/bin/audit-logger.sh \
    /usr/local/bin/session-wrapper.sh \
    /usr/local/bin/entrypoint.sh
    
RUN echo 'session optional pam_exec.so /usr/local/bin/audit-logger.sh' >> /etc/pam.d/sshd

RUN echo "export TERM=xterm" >> /etc/profile
 
# Only port 8080 (web) is needed externally
EXPOSE 8080
 
CMD ["/usr/local/bin/entrypoint.sh"]