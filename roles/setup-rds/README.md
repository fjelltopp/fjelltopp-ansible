Role Name
=========

Simple role for setting up an AWS RDS instance for CKAN 

Requirements
------------


Role Variables
--------------
rds_storage_size: 20 (in Gigabytes)
rds_instance_type: db.t3.small
rds_postgres_version: "13.3"
rds_admin_username: ckan_admin
rds_multi_AZ: false (consider using "true" for production)
rds_backup_retention: 3 (this is a default, for production it should be set to minimum 14)

Dependencies
------------


Example Playbook
----------------


License
-------

GPL2.0

Author Information
------------------

