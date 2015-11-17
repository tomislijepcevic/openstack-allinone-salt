{% from "glance/vars.sls" import GLANCE_PASS %}

keystone_glance_user:
  keystone.user_present:
    - name: glance
    - password: {{ GLANCE_PASS }}
    - email: glance@example.com
    - roles:
      - service:
        - admin
    - require:
      - keystone: keystone_tenants
      - keystone: keystone_roles

keystone_glance_service:
  keystone.service_present:
    - name: glance
    - service_type: image
    - description: OpenStack Image Service

keystone_glance_endpoint:
  keystone.endpoint_present:
    - name: glance
    - publicurl: http://controller:9292
    - internalurl: http://controller:9292
    - adminurl: http://controller:9292
