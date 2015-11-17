{% from "neutron/vars.sls" import configs, ext_nic %}

openstack-neutron:
  pkg.installed

openstack-neutron-ml2:
  pkg.installed:
    - require:
      - pkg: openstack-neutron

openstack-neutron-openvswitch:
  pkg.installed:
    - require:
      - pkg: openstack-neutron

python-neutronclient:
  pkg.installed:
    - require:
      - pkg: openstack-neutron

pyudev:
  pip.installed:
    - require:
      - pkg: python-pip
    - require_in:
      - service: neutron_services

{% for config in configs %}
{% set path = config.path %}
{% for section, values in config.sections.iteritems() %}
{% for key, value in values.iteritems() %}

openstack-config {{path}} {{section}} {{key}}:
  cmd.run:
    - name: openstack-config --set {{path}} {{section}} {{key}} {{value}}
    - onlyif: '[[ $(openstack-config --get {{path}} {{section}} {{key}} ) != {{value}} ]]'
    - require:
      - pkg: openstack-utils
      - pkg: openstack-neutron
    - require_in:
      - service: neutron_services
{% endfor %}
{% endfor %}
{% endfor %}

# Needed b/c openstack-config tool doesn't support multi values - value with
# multiple strings
change:
  file.append:
    - name: /etc/neutron/plugins/ml2/ml2_conf.ini
    - text: 'root_helper = sudo /usr/bin/neutron-rootwrap /etc/neutron/rootwrap.conf'

{% set cmdForGettingService = "keystone tenant-list | awk '/ service / { print $2 }'" %}
openstack-config /etc/neutron/neutron.conf DEFAULT nova_admin_tenant_id:
  cmd.run:
    - name: >
        openstack-config --set /etc/neutron/neutron.conf DEFAULT
        nova_admin_tenant_id $({{ cmdForGettingService }})
    - onlyif: >
        [[ $(openstack-config --get /etc/neutron/neutron.conf DEFAULT
        nova_admin_tenant_id) != $({{ cmdForGettingService }}) ]]
    - require:
      - pkg: openstack-utils
      - pkg: openstack-neutron
    - require_in:
      - service: neutron_services

/etc/neutron/plugin.ini:
    file.symlink:
      - target: /etc/neutron/plugins/ml2/ml2_conf.ini
      - require_in:
        - service: neutron_services

/etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini:
    file.symlink:
      - target: /etc/neutron/plugins/ml2/ml2_conf.ini
      - force: True
      - require_in:
        - service: neutron_services

nova_restart_services:
  service.running:
    - names:
      - qpidd
      - openstack-nova-api
      - openstack-nova-scheduler
      - openstack-nova-conductor
      - openstack-nova-compute
    - restart: True
    - require_in:
      - service: neutron_services

service qpidd restart:
  cmd.run:
    - require_in:
      - service: neutron_services

neutron_services:
  service.running:
    - names:
      - neutron-server
      - openvswitch
      - neutron-l3-agent
      - neutron-dhcp-agent
      - neutron-metadata-agent
      - neutron-openvswitch-agent
    - enable: True
    - order: last
    - watch_in:
      - qpidd
      - openstack-nova-api
      - openstack-nova-scheduler
      - openstack-nova-conductor
      - openstack-nova-compute

ovs_add_internal_bridge:
  cmd.run:
    - name: ovs-vsctl add-br br-int
    - unless: ovs-vsctl br-exists br-int
    - require:
      - service: openvswitch
    - require_in:
      - service: restart-network

ovs_add_external_bridge:
  cmd.run:
    - name: ovs-vsctl add-br br-ex
    - unless: ovs-vsctl br-exists br-ex
    - require:
      - service: openvswitch
    - require_in:
      - service: restart-network

ovs_add_interface_to_external_bridge:
  cmd.run:
    - name: 'ovs-vsctl --may-exist add-port br-ex {{ ext_nic }}'
    - require:
      - cmd: ovs_add_external_bridge
    - require_in:
      - service: restart-network

/etc/sysconfig/network-scripts/ifcfg-{{ ext_nic }}:
  file.managed:
    - source: salt://neutron/files/ifcfg-ext
    - template: jinja
    - backup: '.bak'
    - require_in:
      - service: restart-network

/etc/sysconfig/network-scripts/ifcfg-br-ex:
  file.managed:
    - source: salt://neutron/files/ifcfg-br-ex
    - template: jinja
    - require_in:
      - service: restart-network

restart-network:
  service.running:
    - name: network
    - restart: True

/root/restore-network:
  file.managed:
    - source: salt://neutron/files/restore-network
    - template: jinja
    - mode: 0744
    - require_in:
      - service: restore-network

/lib/systemd/system/restore-network.service:
  file.managed:
    - source: salt://neutron/files/restore-network.service
    - template: jinja
    - require_in:
      - service: restore-network

restore-network:
  service.running:
    - enable: True
