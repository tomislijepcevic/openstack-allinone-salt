{% from "neutron/vars.sls" import NEUTRON_PASS %}

keystone_neutron_user:
  keystone.user_present:
    - name: neutron
    - password: {{ NEUTRON_PASS }}
    - email: neutron@example.com
    - roles:
      - service:
        - admin
    - require:
      - keystone: keystone_tenants
      - keystone: keystone_roles

keystone_neutron_service:
  keystone.service_present:
    - name: neutron
    - service_type: network
    - description: OpenStack Networking

keystone_neutron_endpoint:
  keystone.endpoint_present:
    - name: neutron
    - publicurl: http://controller:9696
    - adminurl: http://controller:9696
    - internalurl: http://controller:9696
