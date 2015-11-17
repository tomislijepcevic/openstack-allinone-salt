{% from "keystone/vars.sls" import admin_user, demo_user %}

keystone_tenants:
  keystone.tenant_present:
    - names:
      - admin
      - demo
      - service

keystone_roles:
  keystone.role_present:
    - names:
      - admin
      - _member_

keystone_admin_user:
  keystone.user_present:
    - name: admin
    - password: {{ admin_user.password }}
    - email: {{ admin_user.email }}
    - roles:
      - admin:
        - admin
        - _member_
      - service:
        - admin
    - require:
      - keystone: keystone_tenants
      - keystone: keystone_roles

keystone_demo_user:
  keystone.user_present:
    - name: demo
    - password: {{ demo_user.password }}
    - email: {{ demo_user.email }}
    - roles:
      - demo:
         - _member_
    - require:
      - keystone: keystone_tenants
      - keystone: keystone_roles

keystone_keystone_service:
  keystone.service_present:
    - name: keystone
    - service_type: identity
    - description: Openstack Identity Service

keystone_keystone_endpoint:
  keystone.endpoint_present:
    - name: keystone
    - publicurl: http://controller:5000/v2.0
    - internalurl: http://controller:5000/v2.0
    - adminurl: http://controller:35357/v2.0
