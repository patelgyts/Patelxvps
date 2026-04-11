FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Basic packages + SSH + curl + wget + unzip
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
    openssh-server \
    curl \
    wget \
    unzip \
    sudo \
    nano && \
    mkdir /var/run/sshd

# Root password set (change later if needed)
RUN echo "root:railway" | chpasswd

# Allow root login
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH port
EXPOSE 22

# Install ngrok
RUN curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
| tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && \
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
| tee /etc/apt/sources.list.d/ngrok.list && \
apt update && apt install ngrok -y

# Start SSH + ngrok
CMD service ssh start && \
ngrok config add-authtoken YOUR_NGROK_TOKEN && \
ngrok tcp 22
