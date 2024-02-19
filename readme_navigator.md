Local Navigator dev environment currently slighlty differs from CKAN. All three components, API, Engine and UI are using host's local storage as pod's persistent volume (PV), which means that pods are using local repository directly to run the application. E.g. if `minikube_host_mountpath` variable is set correctly, to the director above navigator_engine, navigator_api and navigator_ui, then {{ minikube_host_mountpath }}/navigator_api will be mounted by the API container under /var/www/navigator_api. Then, the init container is going to create .venv directory inside this dir and it's going to build the whole venv in there. Pod is going to run as the user that created minikube (ansible_user_uid variable). This should make local development easier, as changes to the local repository are immediately visible by the container. The current drawback is that all the build artifacts (both from Node and pipenv) are also created on host, not inside the temporary containers.


# Setup
* Minikube setup is the same as for CKAN (see notes below, make sure to use the right minikube_host_mountpath), just make sure to use a dedicated inventory file, e.g. `ansible-playbook -i inventory/local_dev_navigator setup_local_dev.yml -t setup`
* There's a dedicated playbook for the deployment: `ansible-playbook -i inventory/local_dev_navigator deploy_navigator.yml -t deploy`. All the variables are available in ./roles/navigator/defaults/main.yml file, they can be overwriten in group_vars/_env_ or via inventory file.

# MINIKUBE notes
* make sure that you're using the right inventory file, e.g. inventory/local_dev_navigator, once set minikube won't allow to change miinikube_host_mountpath
* `minikube_host_mountpath` path needs to contain all navigator repositories, currently:
  - navigator_api
  - navigator_engine
  - navigator_ui
* minikube pods will assume local username UID, so that the files created within `minikube_host_mountpath` will retain local user ownership


