#!/bin/bash
set -ex

ssh-keygen -A 

systemctl enable sshd
systemctl enable libvirtd
systemctl enable cloud-init
systemctl enable cloud-init-local
systemctl enable cloud-config
systemctl enable cloud-final
systemctl enable google-guest-agent
systemctl enable google-osconfig-agent
systemctl enable google-startup-scripts.service
