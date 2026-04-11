FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
apt-get install -y openssh-server curl wget unzip sudo nano && \
mkdir /var/run/sshd

RUN echo "root:railway" | chpasswd

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

EXPOSE 22

RUN curl -fsSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | \
tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && \
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | \
tee /etc/apt/sources.list.d/ngrok.list && \
apt update && \
apt install ngrok -y

CMD service ssh start && \
ngrok config add-authtoken YOUR_NGROK_TOKEN && \
ngrok tcp 22
