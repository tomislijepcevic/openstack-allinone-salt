{% from "glance/vars.sls" import configs %}

openstack-glance:
  pkg.installed

python-glanceclient:
  pkg.installed:
    - require:
      - pkg: openstack-glance

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
      - cmd: glance_manage_sync
      - service: openstack-glance
{% endfor %}
{% endfor %}
{% endfor %}

glance_manage_sync:
  cmd.run:
    - name: 'su -s /bin/sh -c "glance-manage db_sync" glance'
    - unless: v=$(su -s /bin/sh -c "glance-manage db_version" glance) && [[ $v != 0 ]]
    - require:
      - cmd: openstack-config /etc/glance/glance-api.conf DEFAULT sql_connection
      - cmd: openstack-config /etc/glance/glance-registry.conf DEFAULT sql_connection
      - pkg: openstack-glance

glance_services:
  service.running:
    - names:
      - openstack-glance-api
      - openstack-glance-registry
    - enable: True
    - require:
      - pkg: openstack-glance
    - order: last
