#!/bin/bash

# Update and install NGINX
sudo apt-get update
sudo apt-get install -y nginx

# Set the default region and zone
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a

# Create a new VM instance using gcloud
gcloud compute instances create gcelab2 --machine-type e2-medium --zone=us-central1-a

# Print VM instances to verify
gcloud compute instances list
