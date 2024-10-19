Role Name
=========

Role for deploying CKAN on Kubernetes

Requirements
------------


Role Variables
--------------
 application_namespace
 ckan_image
 ckan_datapusher_url
 ckan_datastore_read_url
 ckan_datastore_write_url
 ckan_max_upload_size_mb
 ckan_cache_expires
 ckan_redis_url
 ckan_site_url
 ckan_solr_url
 ckan_sqlalchemy_url
 ckan_ds_ro_pass
 ckan_postgres_password
 ckan_collaborators
 ckan_fqdn
 ckan_ds_ro_pass
 ckan_postgres_password
 ckan_jwt_private_key
 ckan_jwt_public_key
 giftless_image
 solr_image


Dependencies
------------
Requires either 'minikube-setup' or 'setup-eks' roles to be executed before (or any other k8s environment)

Example Playbook
----------------
- hosts: all
  connection: local
  become: false
  roles:
    - { role: ckan, tags: ["deploy", "all"] }


License
-------

GPL2.0

Author Information
------------------
