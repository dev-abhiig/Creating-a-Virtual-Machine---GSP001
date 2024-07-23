#!/bin/bash

# Get the current project ID, region, and zone dynamically
PROJECT_ID=$(gcloud config get-value project)
ZONE=$(gcloud config get-value compute/zone)

# Color codes for output
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

BG_BLACK=$(tput setab 0)
BG_RED=$(tput setab 1)
BG_GREEN=$(tput setab 2)
BG_YELLOW=$(tput setab 3)
BG_BLUE=$(tput setab 4)
BG_MAGENTA=$(tput setab 5)
BG_CYAN=$(tput setab 6)
BG_WHITE=$(tput setab 7)

BOLD=$(tput bold)
RESET=$(tput sgr0)

# Start message
echo "${YELLOW}${BOLD}Starting${RESET} ${GREEN}${BOLD}Execution${RESET}"

# Create VM instance
gcloud compute instances create gcelab \
  --project=$PROJECT_ID \
  --zone=$ZONE \
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

# SSH into the VM and install Nginx
gcloud compute ssh --zone "$ZONE" "gcelab" --project "$PROJECT_ID" --quiet --command "sudo apt-get update && sudo apt-get install -y nginx && ps auwx | grep nginx"

# Install Nginx locally (for the case of testing or multiple instances)
sudo apt-get update
sudo apt-get install -y nginx
ps auwx | grep nginx

# Create firewall rule to allow HTTP traffic
gcloud compute firewall-rules create allow-http \
  --network=default \
  --allow=tcp:80 \
  --target-tags=http-server

# End message
echo "${RED}${BOLD}Congratulations${RESET} ${WHITE}${BOLD}for${RESET} ${GREEN}${BOLD}Completing the Lab !!!${RESET}"
