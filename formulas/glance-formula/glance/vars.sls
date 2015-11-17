{% set openstack = pillar.get('openstack', {}) %}
{% set glance = openstack.get('glance', {}) %}

{% set GLANCE_DBPASS = glance.get('GLANCE_DBPASS', 'glance-db-pw') %}
{% set GLANCE_PASS = glance.get('GLANCE_PASS', 'glance-pw') %}
{% set cirros_image = glance.get('cirros_image', {
    'name': 'cirros-0.3.2-x86_64',
    'location': 'http://cdn.download.cirros-cloud.net/0.3.2/cirros-0.3.2-x86_64-disk.img',
  })
%}

{% set configs = glance.get('configs', [
  {
    'path': '/etc/glance/glance-api.conf',
    'sections': {
      'DEFAULT': {
        'sql_connection': 'mysql://glance:{0}@controller/glance'.format(GLANCE_DBPASS),
        'rpc_backend': 'qpid',
        'qpid_hostname': 'controller',
      },
      'keystone_authtoken': {
        'auth_uri': 'http://controller:5000',
        'auth_host': 'controller',
        'auth_port': '35357',
        'auth_protocol': 'http',
        'admin_tenant_name': 'service',
        'admin_user': 'glance',
        'admin_password': GLANCE_PASS,
      },
      'paste_deploy': {
        'flavor': 'keystone',
      },
    },
  }, {
    'path': '/etc/glance/glance-registry.conf',
    'sections': {
      'DEFAULT': {
        'sql_connection': 'mysql://glance:{0}@controller/glance'.format(GLANCE_DBPASS),
      },
      'keystone_authtoken': {
        'auth_uri': 'http://controller:5000',
        'auth_host': 'controller',
        'auth_port': '35357',
        'auth_protocol': 'http',
        'admin_tenant_name': 'service',
        'admin_user': 'glance',
        'admin_password': GLANCE_PASS,
      },
      'paste_deploy': {
        'flavor': 'keystone',
      },
    },
  },
])
%}
