FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ── Switch to US mirror ──────────────────────────────────────────────────────
RUN sed -i \
      -e 's|http://archive.ubuntu.com/ubuntu|http://us.archive.ubuntu.com/ubuntu|g' \
      -e 's|http://security.ubuntu.com/ubuntu|http://us.archive.ubuntu.com/ubuntu|g' \
      /etc/apt/sources.list

# ── Packages — NO shellinabox (using Guacamole for web access) ───────────────
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
    uuid-runtime \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ── SSH server config ────────────────────────────────────────────────────────
# ListenAddress 0.0.0.0 — Guacamole connects to SSH from outside the container
RUN mkdir -p /var/run/sshd && \
    sed -i \
      -e 's/#PermitRootLogin.*/PermitRootLogin no/' \
      -e 's/#PasswordAuthentication.*/PasswordAuthentication yes/' \
      /etc/ssh/sshd_config && \
    printf '\n# Sandbox settings\nListenAddress 0.0.0.0\nForceCommand /usr/local/bin/session-wrapper.sh\nAllowUsers intern1 intern2 intern3\nAllowTcpForwarding no\nX11Forwarding no\nPermitTunnel no\n' \
      >> /etc/ssh/sshd_config

# ── Pre-generate SSH host keys ───────────────────────────────────────────────
RUN ssh-keygen -A

# ── Users ────────────────────────────────────────────────────────────────────
RUN useradd -m -s /bin/bash intern1 && \
    useradd -m -s /bin/bash intern2 && \
    useradd -m -s /bin/bash intern3 && \
    echo 'intern1:intern123' | chpasswd && \
    echo 'intern2:intern123' | chpasswd && \
    echo 'intern3:intern123' | chpasswd

# ── Directories + PAM ────────────────────────────────────────────────────────
RUN mkdir -p /shared /var/log/audit/sessions && \
    chmod 1777 /shared && \
    chmod 777 /var/log/audit && \
    echo 'session optional pam_exec.so /usr/local/bin/audit-logger.sh' >> /etc/pam.d/sshd && \
    echo 'export TERM=xterm' >> /etc/profile

# ── Scripts ──────────────────────────────────────────────────────────────────
COPY scripts/audit-logger.sh    /usr/local/bin/audit-logger.sh
COPY scripts/session-wrapper.sh /usr/local/bin/session-wrapper.sh
COPY scripts/entrypoint.sh      /usr/local/bin/entrypoint.sh

RUN chmod +x \
    /usr/local/bin/audit-logger.sh \
    /usr/local/bin/session-wrapper.sh \
    /usr/local/bin/entrypoint.sh

# Port 22 — Guacamole connects here
EXPOSE 22

CMD ["/usr/local/bin/entrypoint.sh"]