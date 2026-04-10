FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Locale + base packages + ngrok via official apt repo
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        locales \
        openssh-server \
        wget \
        curl \
        gnupg \
        unzip && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
        | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && \
    echo "deb https://ngrok-agent.s3.amazonaws.com bookworm main" \
        | tee /etc/apt/sources.list.d/ngrok.list && \
    apt-get update && \
    apt-get install -y ngrok && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.utf8

ARG Ngrok
ARG Password
ARG re

ENV Ngrok=${Ngrok} \
    re=${re}

# Configure SSH
RUN mkdir -p /run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo "root:${Password}" | chpasswd

# Entrypoint
RUN printf '#!/bin/bash\n\
set -e\n\
ngrok config add-authtoken "${Ngrok}"\n\
ngrok tcp 22 --region "${re}" > /dev/null 2>&1 &\n\
exec /usr/sbin/sshd -D\n' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 22 80 443 3306 5130 5131 5132 5133 5134 5135 8080 8888

CMD ["/entrypoint.sh"]
