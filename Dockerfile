FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    sudo \
    curl \
    wget \
    git \
    python3 \
    python3-pip \
    net-tools \
    iputils-ping \
    tree \
    htop \
    shellinabox \
    uuid-runtime \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# SSH server config - clean up deprecated options
RUN mkdir -p /var/run/sshd && \
    sed -i \
      -e '/RhostsRSAAuthentication/d' \
      -e '/RSAAuthentication/d' \
      -e 's/#PermitRootLogin.*/PermitRootLogin no/' \
      -e 's/#PasswordAuthentication.*/PasswordAuthentication yes/' \
      /etc/ssh/sshd_config && \
    printf '\n# Sandbox settings\nListenAddress 127.0.0.1\nForceCommand /usr/local/bin/session-wrapper.sh\nAllowUsers intern1 intern2 intern3\nAllowTcpForwarding no\nX11Forwarding no\nPermitTunnel no\n' \
      >> /etc/ssh/sshd_config

RUN useradd -m -s /bin/bash intern1 && \
    useradd -m -s /bin/bash intern2 && \
    useradd -m -s /bin/bash intern3 && \
    echo 'intern1:intern123' | chpasswd && \
    echo 'intern2:intern123' | chpasswd && \
    echo 'intern3:intern123' | chpasswd

RUN mkdir -p /shared /var/log/audit/sessions && \
    chmod 1777 /shared && \
    chmod 777 /var/log/audit && \
    echo 'session optional pam_exec.so /usr/local/bin/audit-logger.sh' >> /etc/pam.d/sshd && \
    echo 'export TERM=xterm' >> /etc/profile

COPY scripts/audit-logger.sh    /usr/local/bin/audit-logger.sh
COPY scripts/session-wrapper.sh /usr/local/bin/session-wrapper.sh
COPY scripts/entrypoint.sh      /usr/local/bin/entrypoint.sh

RUN chmod +x \
    /usr/local/bin/audit-logger.sh \
    /usr/local/bin/session-wrapper.sh \
    /usr/local/bin/entrypoint.sh

RUN ssh-keygen -A

EXPOSE 8080

CMD ["/usr/local/bin/entrypoint.sh"]