#!/bin/bash
dnf update -y
dnf install -y docker
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

for i in {1..24}; do
  if aws s3 cp "s3://${SWARM_TOKEN_BUCKET}/swarm-token" "/home/ec2-user/worker_token"; then
    echo "Token found on s3"
    break
  else
    echo "Token not found yet"
    sleep 5
  fi
done

if [ ! -s /home/ec2-user/worker_token ]; then
  echo "Token not found."
  exit 1
fi

docker swarm join --token "$(cat /home/ec2-user/worker_token)" "${SWARM_MANAGER_PRIVATE_IP}:2377"
