openstack:
  common:
    ip: {{ grains['ip_interfaces']['p2p1'][0] }}
  neutron:
    ext_nic: 'p7p1'

# keystone.token: 'ADMIN_TOKEN'
# keystone.endpoint: 'http://127.0.0.1:35357/v2.0'
