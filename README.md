# Basic introduction to Fjelltopp Infrastructure
More detailed documentation is available in Confluence

## (optional) Set up a Virtual Machine
It is recommended that if your host is Windows or Mac, the installation will be done in a Virtual Machine
* Create a Ubuntu VM
* Install SSH Server
  * `sudo apt install openssh-client`
  * `sudo apt install openssh-server`
* Install Docker by following instructions in <https://docs.docker.com/engine/install/ubuntu/>
* Install pipenv by following instructions in <https://pipenv.pypa.io/en/latest/install/>
* Set up SSH port forwarding for your VM by accessing
Machine &rarr; Settings &rarr; Network &rarr; Adapter 1 &rarr; Advanced &rarr; Port Forwarding and
adding the following entry:

| Name | Protocol | Host IP | Host Port | Guest IP | Guest Port |
| ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
| SSH | TCP | 127.0.01 | 2222 | 10.0.0.2.15 | 22 |

Guest IP can be retrieved by running `ip addr show` in the VM.  

## Prepare Environment (install Ansible)
* `pipenv sync`
* `pipenv shell`
* `ansible-galaxy install -r roles/requirements.yml --force` # (on first run only)
## Run local setup playbook (install Minikube and deploys CKAN)
* use inventory template from ./inventory/local_dev_example as a base for your own inventory file (instructions inside)
* Setup requires root privileges for Minikube installation, if your account requires password on `sudo` then add "-K" after the "setup" string (it's going to ask for your password)
* `ansible-playbook -i inventory/local_dev setup_local_dev.yml -t setup`

## Run ckan deployment playbook to deploy CKAN to the new environment
`ansible-playbook -i inventory/local_dev deploy_ckan.yml -t deploy`

## Minikube FQDN
An IP of Minikube cluster will get added to /etc/hosts at the end of execution of setup_local_dev playbook.

## List Minikube profiles
`minikube profile list`

## Select default Minikube profile
Default profile is set during setup_local_dev playbook execution. With multiple profiles present, if you want to switch first list available profiles, and then select the new default
`minikube profile _profile_name`

## Access Kubernetes dashboard
`minikube dashboard`
### or when running minikube inside a VM (requires some kind of proxy, e.g. FoxyProxy and ssh socks proxy tunnel)
`minikube dashboard --url`

## If you want to use custom build local images with Minikube you need to build them into Minikube's internal docker cache, first use Minikube's Docker environment
`eval $(minikube docker-env)`
### Then build and push docker image into minikube, here it's CKAN image
`docker build -t ckan/ckan:2.9.3`

## Sync local repository into CKAN pod
setup_local_dev.ymlscript syncs local files or directories with CKAN pod running on Minikube. Run it with two parameters, first: local_path and second: remote_path, where remote path is a path already inside /usr/lib/ckan, so it can be just / '
Example: `./sync_local_repo.sh /home/michal/dms/ckanext-dms/ /`

