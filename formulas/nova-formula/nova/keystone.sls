{% from "nova/vars.sls" import NOVA_PASS %}

keystone_nova_user:
  keystone.user_present:
    - name: nova
    - password: {{ NOVA_PASS }}
    - email: nova@example.com
    - roles:
      - service:
        - admin
    - require:
      - keystone: keystone_tenants
      - keystone: keystone_roles

keystone_nova_service:
  keystone.service_present:
    - name: nova
    - service_type: compute
    - description: OpenStack Compute

keystone_nova_endpoint:
  keystone.endpoint_present:
    - name: nova
    - publicurl: http://controller:8774/v2/%(tenant_id)s
    - internalurl: http://controller:8774/v2/%(tenant_id)s
    - adminurl: http://controller:8774/v2/%(tenant_id)s
