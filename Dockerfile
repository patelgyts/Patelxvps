FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
apt-get upgrade -y && \
apt-get install -y \
openssh-server \
wget \
curl \
unzip \
locales \
ca-certificates && \
update-ca-certificates

RUN wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip && \
unzip ngrok-v3-stable-linux-amd64.zip && \
mv ngrok /usr/local/bin/ngrok && \
chmod +x /usr/local/bin/ngrok && \
rm ngrok-v3-stable-linux-amd64.zip

RUN localedef -i en_US -c -f UTF-8 \
-A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG=en_US.utf8

ARG Ngrok
ARG Password
ARG re

ENV Ngrok=${Ngrok}
ENV Password=${Password}
ENV re=${re}

RUN mkdir /var/run/sshd && \
echo root:${Password} | chpasswd && \
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

RUN echo '#!/bin/bash' > /start.sh && \
echo 'ngrok config add-authtoken ${Ngrok}' >> /start.sh && \
echo 'ngrok tcp 22 --region ${re} &' >> /start.sh && \
echo '/usr/sbin/sshd -D' >> /start.sh && \
chmod +x /start.sh

EXPOSE 22

CMD ["/start.sh"]
