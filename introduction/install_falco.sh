#!/bin/bash

set -x # to test stderr output in /var/log/killercoda

echo starting... # to test stdout output in /var/log/killercoda

sleep 5

# deploy falco with its default settings
sudo -H -u root helm repo add falcosecurity https://falcosecurity.github.io/charts
sudo -H -u root helm repo update
sudo -H -u root helm install falco falcosecurity/falco --namespace falco --create-namespace

touch /tmp/finished
