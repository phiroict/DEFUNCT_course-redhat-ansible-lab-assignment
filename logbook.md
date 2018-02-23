# Startup
Created git repo at: [Git](https://github.com/phiroict/course-redhat-ansible-lab-assignment.git)

# Requirements

* GitHub repository
* Playbooks to deploy internal three-tier application
* Install HA Ansible Tower

Check lab 5 notes for configuration of openstack and redeploy on a fresh ansible for openstack project


# Restart Openstack services after server restart:
```
# from the workstation:
# cd
source keystonerc_admin
openstack server list
nova start db app1 app2 frontend
openstack server list
```


# Build

We need to set up a new ansible tower on lab5 guid: aa0f.  Ansible tower.
https://tower1.aa0f.example.opentlc.com
And a openstack instance as well : 1db6                    Three tier project.


## Server stack
### Ansible tower stack
Notes:
The keys need to be in the /var/lib/awx/SSH (openstack.pem) in there manually.
Also, you need to have the ssh.cfg and the ansible.cfg in the root of the project, nowhere else.



### Application stack static (not used)


### Application stack openshift for QA
Create with ansible using the os_ modules

### Application stack for AWS for production
Create with ansible using the ec2_ modules.





## Github created at [Git](https://github.com/phiroict/course-redhat-ansible-lab-assignment.git)

## Playbook deploy a three-tier application
Mainly from the lab5 as well. Should pretty well work.

### Provision stack
From lab5 create servers, flavors and all that.

### Deploy application
From the lab5
### Test application
Needs to be written:
* socket check
* response check
* round robin check.

## Install Tower
Installed on the aa0f service so we are going to use that for this assignment

# Steps
From https://labs.opentlc.com/catalog/explorer
* Recreate ansible tower lab project
* Recreate Three tier application project from the catalog.

## provision ansible tower
By script
<git-assignment>/code/ansible-tower/cmd_install_tower.sh

```yaml
---
  - name: Install the installation scripts for ansible and configure database
    hosts: jumphost
    become: yes
    gather_facts: False
    tasks:
      - name: Get installation script
        unarchive:
          src: https://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-latest.tar.gz
          dest: /root/
          remote_src: yes
        creates: /root/ansible-tower-setup-3.2.3
      - name: Get the folder name of the installation
        find:
          paths: /root
          patterns: 'ansible-tower-setup-*'
          file_type: directory
        register: find_result
      - name:
        debug:
          msg: "results are {{ find_result.files[0].path }}"
      - name: Copy over inventory file
        template:
          src: ./hosts_tower
          dest: "{{ find_result.files[0].path }}/inventory"
          backup: yes
      - name: Execute installation
        shell: bash setup.sh
        args:
          chdir: "{{ find_result.files[0].path }}"

```
Connect to it by:
https://tower1.aa0f.example.opentlc.com/#/home
Test: Ok.

## Provision Openstack environment.
* On machine workstation-1db6.rhpds.opentlc.com
Follow instructions setting up from lab5

Copy over keys:
```
sudo -i
export GUID=<My GUID>
scp ctrl-${GUID}.rhpds.opentlc.com:/etc/yum.repos.d/open.repo /etc/yum.repos.d/open.repo
yum install python-openstackclient
# Copy the keystonerc_admin file from ctrl.example.com and source it in root's home directory to set environment variables and verify the OpenStack environment:

scp ctrl.example.com:/root/keystonerc_admin /root/
source /root/keystonerc_admin
openstack hypervisor list
```
Returned

```
+----+---------------------+
| ID | Hypervisor Hostname |
+----+---------------------+
|  1 | comp00.example.com  |
|  2 | comp01.example.com  |
+----+---------------------+
```

Ok

* Now install the keys
```
wget http://www.opentlc.com/download/ansible_bootcamp/openstack_keys/openstack.pub
cat openstack.pub  >> /home/cloud-user/.ssh/authorized_keys
```
Note that this will inject it into the cloud-user keystore.
* Install shade
```
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install `ls *epel*.rpm`
yum install -y python python-devel python-pip gcc ansible
pip install shade
```

* Install cloud definitions
```
workstation# mkdir /etc/openstack
workstation# cat << EOF > /etc/openstack/clouds.yaml
clouds:
  ospcloud:
    auth:
      auth_url: http://192.168.0.20:5000/
      password: r3dh4t1!
      project_name: admin
      username: admin
    identity_api_version: '3.0'
    region_name: RegionOne
ansible:
  use_hostnames: True
  expand_hostvars: False
  fail_on_errors: True
EOF
```
* Install image, from course-redhat-ansible-windows-chapter7/code/provisioning-QA/cmd_read_image.sh but run from the
workstation.
Runs playbook pb_read_image.yml.

* Check oauth connection:
```
ansible localhost -m os_auth -a cloud=ospcloud
```
Result : ok

* Create networks
course-redhat-ansible-windows-chapter7/code/provisioning-QA/cmd_create_networks.sh
(Includes router)

# Create keypair
course-redhat-ansible-windows-chapter7/code/provisioning-QA/cmd_create_sshkeys.sh

* Create flavor
course-redhat-ansible-windows-chapter7/code/provisioning-QA/cmd_create_flavor.sh

* Create the security groups
course-redhat-ansible-windows-chapter7/code/provisioning-QA/cmd_create_security.sh

* Build instances

