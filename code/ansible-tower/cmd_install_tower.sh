#!/usr/bin/env bash
source ./set-env.sh
ansible-playbook -i installation_installation_ansible_tower_hosts pb_installation_script_at.yml -e "guid=${GUID}"

