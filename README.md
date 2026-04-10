curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc
echo "deb https://ngrok-agent.s3.amazonaws.com bookworm main"
apt-get install -y ngrok
