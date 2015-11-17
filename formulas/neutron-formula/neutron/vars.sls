{% import "nova/vars.sls" as nova with context %}
{% import "keystone/vars.sls" as keystone with context %}
{% import "common/vars.sls" as common with context %}

{% set openstack = pillar.get('openstack', {}) %}
{% set neutron = openstack.get('neutron', {}) %}

{% set NEUTRON_DBPASS = neutron.get('NEUTRON_DBPASS', 'neutron-db-pw') %}
{% set NEUTRON_PASS = neutron.get('NEUTRON_PASS', 'neutron-pw') %}
{% set METADATA_SECRET = neutron.get('METADATA_SECRET', 'METADATA_SECRET') %}

{% set ext_nic = neutron.get('ext_nic', 'eth0' ) %}
{% set ext_nic_mac = grains['hwaddr_interfaces'][ext_nic] %}

{% set ext_net = neutron.get('ext_net', {
  'gateway': '192.168.1.1',
  'cidr': '192.168.1.0/24',
  'pool': {
    'start': '192.168.1.130',
    'end': '192.168.1.140',
  },
}) %}

{% set demo_net = neutron.get('ext_net', {
  'gateway': '10.0.1.1',
  'cidr': '10.0.1.0/24',
}) %}

{% set configs = neutron.get('configs', [
{
  'path': '/etc/neutron/neutron.conf',
  'sections': {
    'database': {
      'connection': 'mysql://neutron:{0}@controller/neutron'.format(NEUTRON_DBPASS),
    },
    'DEFAULT': {
      'auth_strategy': 'keystone',
      'rpc_backend': 'neutron.openstack.common.rpc.impl_qpid',
      'qpid_hostname': 'controller',
      'notify_nova_on_port_status_changes': 'True',
      'notify_nova_on_port_data_changes': 'True',
      'nova_url': 'http://controller:8774/v2',
      'nova_admin_username': 'nova',
      'nova_admin_password': nova.NOVA_PASS,
      'nova_admin_auth_url': 'http://controller:35357/v2.0',
      'core_plugin': 'neutron.plugins.ml2.plugin.Ml2Plugin',
      'service_plugins': 'neutron.services.l3_router.l3_router_plugin.L3RouterPlugin',
      'agent_down_time': 75,
      'report_interval': 5,
    },
    'keystone_authtoken': {
      'auth_uri': 'http://controller:5000',
      'auth_host': 'controller',
      'auth_protocol': 'http',
      'auth_port': '35357',
      'admin_tenant_name': 'service',
      'admin_user': 'neutron',
      'admin_password': NEUTRON_PASS,
    },
  },
}, {
  'path': '/etc/neutron/plugins/ml2/ml2_conf.ini',
  'sections': {
    'ml2': {
      'type_drivers': 'gre',
      'tenant_network_types': 'gre',
      'mechanism_drivers': 'openvswitch',
    },
    'ml2_type_gre': {
      'tunnel_id_ranges': '1:1000',
    },
    'agent': {
      'tunnel_types': 'gre',
    },
    'ovs': {
      'local_ip': common.ip,
      'tunnel_type': 'gre',
      'enable_tunneling': 'True'
    },
    'securitygroup': {
      'firewall_driver': 'neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver',
      'enable_security_group': 'True',
    },
  },
}, {
  'path': '/etc/nova/nova.conf',
  'sections': {
    'DEFAULT': {
      'network_api_class': 'nova.network.neutronv2.api.API',
      'neutron_url': 'http://controller:9696',
      'neutron_auth_strategy': 'keystone',
      'neutron_admin_tenant_name': 'service',
      'neutron_admin_username': 'neutron',
      'neutron_admin_password': NEUTRON_PASS,
      'neutron_admin_auth_url': 'http://controller:35357/v2.0',
      'linuxnet_interface_driver': 'nova.network.linux_net.LinuxOVSInterfaceDriver',
      'firewall_driver': 'nova.virt.firewall.NoopFirewallDriver',
      'security_group_api': 'neutron',
      'service_neutron_metadata_proxy': 'True',
      'neutron_metadata_proxy_shared_secret': METADATA_SECRET,
    },
  },
}, {
  'path': '/etc/neutron/l3_agent.ini',
  'sections': {
    'DEFAULT': {
      'interface_driver': 'neutron.agent.linux.interface.OVSInterfaceDriver',
      'use_namespaces': 'True',
    },
  },
}, {
  'path': '/etc/neutron/dhcp_agent.ini',
  'sections': {
    'DEFAULT': {
      'interface_driver': 'neutron.agent.linux.interface.OVSInterfaceDriver',
      'dhcp_driver': 'neutron.agent.linux.dhcp.Dnsmasq',
      'use_namespaces': 'True',
    },
  },
}, {
  'path': '/etc/neutron/metadata_agent.ini',
  'sections': {
    'DEFAULT': {
      'auth_url': 'http://controller:5000/v2.0',
      'auth_region': 'regionOne',
      'admin_tenant_name': 'service',
      'admin_user': 'neutron',
      'admin_password': NEUTRON_PASS,
      'nova_metadata_ip': 'controller',
      'metadata_proxy_shared_secret': METADATA_SECRET,
    },
  },
}
]) %}
