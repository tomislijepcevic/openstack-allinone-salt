{% set openstack = pillar.get('openstack', {}) %}
{% set keystone = openstack.get('keystone', {}) %}

{% set ADMIN_TOKEN = keystone.get('ADMIN_TOKEN', 'ADMIN_TOKEN') %}
{% set KEYSTONE_DBPASS = keystone.get('KEYSTONE_DBPASS', 'keystone-db-pw') %}

{% set admin_user = keystone.get('admin_user', {
    'password': 'admin-pw',
    'email': 'tomi.slijepcevic@gmail.com',
  })
%}

{% set demo_user = keystone.get('demo_user', {
    'password': 'demo-pw',
    'email': 'demo@gmail.com',
  })
%}

{% set os_env = keystone.get('os_env', {
    'OS_SERVICE_TOKEN': ADMIN_TOKEN,
    'OS_SERVICE_ENDPOINT': 'http://controller:35357/v2.0',
    'OS_AUTH_URL': 'http://controller:35357/v2.0',
  })
%}

{% set os_env_adminrc = keystone.get('os_env_adminrc', {
    'OS_USERNAME': 'admin',
    'OS_PASSWORD': 'admin-pw',
    'OS_TENANT_NAME': 'admin',
    'OS_AUTH_URL': os_env.OS_AUTH_URL,
  })
%}

{% set configs = keystone.get('configs', [{
  'path': '/etc/keystone/keystone.conf',
  'sections': {
      'DEFAULT': {
        'admin_token': ADMIN_TOKEN
      },
      'sql': {
        'connection': 'mysql://keystone:{0}@controller/keystone'.format(KEYSTONE_DBPASS),
      },
    }
  }])
%}
