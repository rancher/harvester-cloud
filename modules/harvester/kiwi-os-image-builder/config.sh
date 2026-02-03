#!/bin/bash
set -ex

systemctl enable sshd
systemctl enable libvirtd
systemctl enable cloud-init
systemctl enable cloud-init-local
systemctl enable cloud-config
systemctl enable cloud-final
