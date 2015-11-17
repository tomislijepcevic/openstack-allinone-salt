{% set openstack = pillar.get('openstack', {}) %}
{% set cinder = openstack.get('cinder', {}) %}

{% set CINDER_DBPASS = cinder.get('CINDER_DBPASS', 'cinder-db-pw') %}
{% set CINDER_PASS = cinder.get('CINDER_PASS', 'cinder-pw') %}
{% set CINDER_VOLUME = cinder.get('CINDER_VOLUME', '/dev/sdb') %}

{% set configs = cinder.get('configs', [{
  'path': '/etc/cinder/cinder.conf',
  'sections': {
    'database': {
      'connection': 'mysql://cinder:{0}@controller/cinder'.format(CINDER_DBPASS),
    },
    'DEFAULT': {
      'auth_strategy': 'keystone',
      'rpc_backend': 'cinder.openstack.common.rpc.impl_qpid',
      'qpid_hostname': 'controller',
    },
    'keystone_authtoken': {
      'auth_uri': 'http://controller:5000',
      'auth_host': 'controller',
      'auth_protocol': 'http',
      'auth_port': '35357',
      'admin_user': 'cinder',
      'admin_tenant_name': 'service',
      'admin_password': CINDER_PASS,
    },
  }
}])
%}
