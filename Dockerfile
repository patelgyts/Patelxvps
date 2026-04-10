FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install required packages
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        locales \
        openssh-server \
        wget \
        curl \
        unzip && \
    locale-gen en_US.UTF-8 && \
    mkdir /var/run/sshd

# Install ngrok (official binary method - Railway compatible)
RUN wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip && \
    unzip ngrok-v3-stable-linux-amd64.zip && \
    mv ngrok /usr/local/bin/ && \
    rm ngrok-v3-stable-linux-amd64.zip

# Root password set via Railway variable
ARG Password
RUN echo "root:${Password}" | chpasswd

# Allow root login
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

EXPOSE 22

# Start SSH + ngrok tunnel
CMD service ssh start && \
    ngrok config add-authtoken $Ngrok && \
    ngrok tcp --region=$re 22
