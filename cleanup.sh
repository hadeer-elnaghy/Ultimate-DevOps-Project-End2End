#!/bin/bash

# Stop and remove all running Docker containers
echo "Stopping all running containers..."
sudo docker stop $(sudo docker ps -aq) 2>/dev/null || true
sudo docker rm $(sudo docker ps -aq) 2>/dev/null || true

# Purge Docker and its configurations
echo "Removing Docker installation..."
sudo apt-get purge -y docker-engine docker docker.io containerd runc docker-ce docker-ce-cli 2>/dev/null || true
sudo rm -rf /var/lib/docker
sudo rm -rf /etc/docker

# Delete Minikube / K8s artifacts if existing
echo "Cleaning Kubernetes and Minikube artifacts..."
minikube delete --all --purge 2>/dev/null || true
sudo rm -rf ~/.kube ~/.minikube

# Autoremove unnecessary packages and clear apt cache
echo "Cleaning apt packages cache..."
sudo apt-get autoremove -y
sudo apt-get clean

echo "Cleanup completed successfully!"
