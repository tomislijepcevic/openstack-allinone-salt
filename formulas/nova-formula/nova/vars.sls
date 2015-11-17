{% import "common/vars.sls" as common with context %}

{% set openstack = pillar.get('openstack', {}) %}
{% set nova = openstack.get('nova', {}) %}

{% set NOVA_DBPASS = nova.get('NOVA_DBPASS', 'nova-db-pw') %}
{% set NOVA_PASS = nova.get('NOVA_PASS', 'nova-pw') %}

{% set configs = nova.get('configs', [{
  'path': '/etc/nova/nova.conf',
  'sections': {
    'database': {
      'connection': 'mysql://nova:{0}@controller/nova'.format(NOVA_DBPASS),
    },
    'DEFAULT': {
      'auth_strategy': 'keystone',
      'rpc_backend': 'nova.openstack.common.rpc.impl_qpid',
      'qpid_hostname': 'controller',
      'my_ip': common.ip,
      'vnc_enabled': 'True',
      'vncserver_listen': '0.0.0.0',
      'vncserver_proxyclient_address': common.ip,
      'novncproxy_base_url': 'http://controller:6080/vnc_auto.html',
      'glance_host': 'controller',
      'vif_plugging_is_fatal': 'False',
      'vif_plugging_timeout': 0,
    },
    'keystone_authtoken': {
      'auth_uri': 'http://controller:5000',
      'auth_host': 'controller',
      'auth_protocol': 'http',
      'auth_port': '35357',
      'admin_user': 'nova',
      'admin_tenant_name': 'service',
      'admin_password': NOVA_PASS,
    }
  },
}])
%}
