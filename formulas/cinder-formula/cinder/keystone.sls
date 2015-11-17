{% from "cinder/vars.sls" import CINDER_PASS %}

keystone_cinder_user:
  keystone.user_present:
    - name: cinder
    - password: {{ CINDER_PASS }}
    - email: cinder@example.com
    - roles:
      - service:
        - admin
    - require:
      - keystone: keystone_tenants
      - keystone: keystone_roles

keystone_cinder_service:
  keystone.service_present:
    - name: cinder
    - service_type: volume
    - description: OpenStack Block Storage

keystone_cinderv2_service:
  keystone.service_present:
    - name: cinderv2
    - service_type: volumev2
    - description: OpenStack Block Storage v2

keystone_cinder_endpoint:
  keystone.endpoint_present:
    - name: cinder
    - publicurl: http://controller:8776/v1/%(tenant_id)s
    - internalurl: http://controller:8776/v1/%(tenant_id)s
    - adminurl: http://controller:8776/v1/%(tenant_id)s

keystone_cinderv2_endpoint:
  keystone.endpoint_present:
    - name: cinderv2
    - publicurl: http://controller:8776/v2/%(tenant_id)s
    - internalurl: http://controller:8776/v2/%(tenant_id)s
    - adminurl: http://controller:8776/v2/%(tenant_id)s

