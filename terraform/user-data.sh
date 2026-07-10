#!/bin/bash
set -euxo pipefail

exec > >(tee /var/log/skillpulse-user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get upgrade -y

apt-get install -y \
  ca-certificates \
  curl \
  git \
  jq \
  docker.io \
  docker-compose-v2

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu

mkdir -p /opt/skillpulse
chown -R ubuntu:ubuntu /opt/skillpulse

{
  echo "SkillPulse EC2 provisioning completed successfully."
  echo "Provisioned at: $(date --iso-8601=seconds)"
  echo "Docker version: $(docker --version)"
  echo "Docker Compose version: $(docker compose version)"
} > /etc/skillpulse-provisioned