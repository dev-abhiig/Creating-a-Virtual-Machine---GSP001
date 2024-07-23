#!/bin/bash

# Set variables
PROJECT_ID=$(gcloud config get-value project)
ZONE=$(gcloud config get-value compute/zone)

# Create VM instance
gcloud compute instances create gcelab \
  --project="$PROJECT_ID" \
  --zone="$ZONE" \
  --machine-type=e2-medium \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
  --metadata=enable-oslogin=true \
  --maintenance-policy=MIGRATE \
  --provisioning-model=STANDARD \
  --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
  --tags=http-server,https-server \
  --create-disk=auto-delete=yes,boot=yes,device-name=gcelab,image=projects/debian-cloud/global/images/debian-11-bullseye-v20230629,mode=rw,size=10,type=projects/$PROJECT_ID/zones/$ZONE/diskTypes/pd-balanced \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --labels=goog-ec-src=vm_add-gcloud \
  --reservation-affinity=any

# Install NGINX on the VM
gcloud compute ssh --zone "$ZONE" "gcelab" --project "$PROJECT_ID" --quiet --command "sudo apt-get update && sudo apt-get install -y nginx && ps auwx | grep nginx"

# Create firewall rule
gcloud compute firewall-rules create allow-http \
  --network=default \
  --allow=tcp:80 \
  --target-tags=allow-http
