Role Name
=========

Role for deploying Profile Editor on Kubernetes

Requirements
------------


Role Variables
--------------
profile_editor_pod_replicas_nr: 1
profile_editor_image: "fjelltopp/python-fjelltopp-base"
profile_editor_image_tag: "3.9"
application_namespace: "profile-editor"
profile_editor_fqdn: "profile-editor.minikube"


Dependencies
------------
Requires either 'minikube-setup' or 'setup-eks' roles to be executed before (or any other k8s environment)

Example Playbook
----------------
<!-- markdownlint-disable MD007 -->
- hosts: all
  connection: local
  become: false
  roles:
    - { role: profile_editor, tags: ["deploy", "all"] }
<!-- markdownlint-enable MD007 -->



License
-------

GPL2.0

Author Information
------------------

