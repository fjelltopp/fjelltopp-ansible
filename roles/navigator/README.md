Role Name
=========

Role for deploying Navigator on Kubernetes

Requirements
------------


Role Variables
--------------
navigator_pod_replicas_nr: 1
navigator_engine_image: "fjelltopp/python-fjelltopp-base"
navigator_engine_image_tag: "3.9"
navigator_api_image: "fjelltopp/python-fjelltopp-base"
navigator_api_image_tag: "3.9"
navigator_ui_image: "node"
navigator_ui_image_tag: "lts-buster"
application_namespace: "navigator"
navigator_fqdn: "navigator.minikube"


Dependencies
------------
Requires either 'minikube-setup' or 'setup-eks' roles to be executed before (or any other k8s environment)

Example Playbook
----------------
- hosts: all
  connection: local
  become: false
  roles:
    - { role: navigator, tags: ["deploy", "all"] }


License
-------

GPL2.0

Author Information
------------------

