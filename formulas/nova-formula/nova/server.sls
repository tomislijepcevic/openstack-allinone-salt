{% from "nova/vars.sls" import configs %}

nova_packages:
  pkg.installed:
    - pkgs:
      - openstack-nova-api
      - openstack-nova-cert
      - openstack-nova-conductor
      - openstack-nova-console
      - openstack-nova-novncproxy
      - openstack-nova-scheduler
      - openstack-nova-compute
      - libvirt-python

python-novaclient:
  pkg.installed:
    - require:
      - pkg: nova_packages

{% set hw_virt = salt['cmd.run']("egrep -c '(vmx|svm)' /proc/cpuinfo") %}
{% if hw_virt == '0' %}
openstack-config --set /etc/nova/nova.conf libvirt virt_type qemu:
  cmd.run:
    - onlyif: >
        [[ $(openstack-config --get /etc/nova/nova.conf libvirt virt_type) != qemu ]]
    - require:
      - pkg: openstack-utils
      - pkg: nova_packages

virt_use_execmem:
    selinux.boolean:
      - value: True
      - persist: True
{% endif %}

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
      - pkg: openstack-keystone
    - require_in:
      - cmd: nova_manage_sync
      - service: nova_services
{% endfor %}
{% endfor %}
{% endfor %}

# Conditional apply doesn't work b/c
# unless: v=$(su -s /bin/sh -c "nova-manage db version" nova) && [[ $v != 0 ]]
nova_manage_sync:
  cmd.run:
    - name: 'su -s /bin/sh -c "nova-manage db sync" nova'
    - require:
      - cmd: openstack-config /etc/nova/nova.conf database connection
      - cmd: openstack-config /etc/nova/nova.conf database connection
      - pkg: nova_packages

nova_services:
  service.running:
    - names:
      - openstack-nova-api
      - openstack-nova-cert
      - openstack-nova-consoleauth
      - openstack-nova-scheduler
      - openstack-nova-conductor
      - openstack-nova-novncproxy
      - libvirtd
      - dbus
      - openstack-nova-compute
    - enable: True
    - require:
      - pkg: nova_packages
    - order: last
