#!/bin/bash

# Check if environment variables are set
if [ -z "$DEVSHELL_PROJECT_ID" ]; then
  echo "Error: DEVSHELL_PROJECT_ID is not set."
  exit 1
fi

if [ -z "$ZONE" ]; then
  echo "Error: ZONE is not set."
  exit 1
fi

# Create the first VM instance (gcelab)
gcloud compute instances create gcelab \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --machine-type=e2-medium \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
  --metadata=enable-oslogin=true \
  --maintenance-policy=MIGRATE \
  --provisioning-model=STANDARD \
  --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
  --tags=http-server,https-server \
  --create-disk=auto-delete=yes,boot=yes,device-name=gcelab,image=projects/debian-cloud/global/images/debian-11-bullseye-v20230629,mode=rw,size=10,type=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/diskTypes/pd-balanced \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --labels=goog-ec-src=vm_add-gcloud \
  --reservation-affinity=any

# Create the second VM instance (gcelab2)
gcloud compute instances create gcelab2 \
  --machine-type=e2-medium \
  --zone=$ZONE

# SSH into the first VM instance and install NGINX
gcloud compute ssh --zone "$ZONE" "gcelab" --project "$DEVSHELL_PROJECT_ID" --quiet --command "sudo apt-get update && sudo apt-get install -y nginx && ps auwx | grep nginx"

# Install NGINX on the local machine (this might not be necessary)
# sudo apt-get update
# sudo apt-get install -y nginx
# ps auwx | grep nginx

# Create a firewall rule to allow HTTP traffic
gcloud compute firewall-rules create allow-http \
  --network=default \
  --allow=tcp:80 \
  --target-tags=http-server
