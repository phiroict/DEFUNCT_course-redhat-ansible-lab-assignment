#!/usr/bin/env bash
source ../../set-env.sh
ansible-playbook -i installation_installation_ansible_tower_hosts --start-at-task "Get the folder name of the installation" pb_installation_script_at.yml -e "guid=${GUID}"

