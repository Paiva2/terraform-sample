#!/bin/bash
dnf update -y
dnf install -y docker
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user
sudo dnf install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm

aws_metadata_token=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
ec2_private_ipv4_address=$(curl -H "X-aws-ec2-metadata-token: $aws_metadata_token" http://169.254.169.254/latest/meta-data/local-ipv4)

aws s3 rm "s3://${SWARM_TOKEN_BUCKET}/swarm-token" || true
docker pull "${APPLICATION_DOCKER_NAME}":"${APPLICATION_VERSION}"
docker swarm init --advertise-addr "$ec2_private_ipv4_address"

docker swarm join-token -q worker > /home/ec2-user/worker_token
aws s3 cp /home/ec2-user/worker_token "s3://${SWARM_TOKEN_BUCKET}/swarm-token"

until docker info 2>/dev/null | grep -q 'Swarm: active'; do
  sleep 5
done

docker service create \
  --name java-app \
  --replicas 3 \
  --dns 10.0.0.2 \
  --dns 8.8.8.8 \
  --publish "${APPLICATION_PORT}":"${APPLICATION_PORT}" \
  --env AWS_REGION="${AWS_REGION}" \
  --env AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
  --env AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
  "${APPLICATION_DOCKER_NAME}":"${APPLICATION_VERSION}"