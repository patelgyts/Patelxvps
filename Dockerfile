FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install base packages + certificates
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        locales \
        openssh-server \
        wget \
        curl \
        unzip \
        ca-certificates && \
    update-ca-certificates

# Install ngrok (direct binary method)
RUN wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip && \
    unzip ngrok-v3-stable-linux-amd64.zip && \
    mv ngrok /usr/local/bin/ngrok && \
    chmod +x /usr/local/bin/ngrok && \
    rm ngrok-v3-stable-linux-amd64.zip

# Locale setup
RUN localedef -i en_US -c -f UTF-8 \
    -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG=en_US.utf8

ARG Ngrok
ARG Password
ARG re

ENV Ngrok=${Ngrok} \
    Password=${Password} \
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
ngrok tcp 22 --region "${re}" &\n\
exec /usr/sbin/sshd -D\n' > /entrypoint.sh && \
chmod +x /entrypoint.sh

EXPOSE 22 80 443 8080 8888

CMD ["/entrypoint.sh"]
