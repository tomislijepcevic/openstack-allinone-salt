{% from "cinder/vars.sls" import configs %}

openstack-cinder:
  pkg.installed

scsi-target-utils:
  pkg.installed:
    - require:
      - pkg: openstack-cinder

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
      - pkg: openstack-cinder
    - require_in:
      - cmd: cinder_manage_sync
      - service: cinder_services
{% endfor %}
{% endfor %}
{% endfor %}

cinder_manage_sync:
  cmd.run:
    - name: 'su -s /bin/sh -c "cinder-manage db sync" cinder'
    - unless: v=$(su -s /bin/sh -c "cinder-manage db version" cinder) && [[ $v != 0 ]]
    - require:
      - cmd: openstack-config /etc/cinder/cinder.conf database connection
      - mysql_database: cinder
      - pkg: openstack-cinder

cinder_services:
  service.running:
    - names:
      - openstack-cinder-api
      - openstack-cinder-scheduler
      - openstack-cinder-volume
    - enable: True
    - require:
      - pkg: openstack-cinder
    - order: last

tgtd:
  service.running:
    - enable: True
    - require:
      - pkg: openstack-cinder
      - pkg: scsi-target-utils
    - watch:
      - file: /etc/tgt/targets.conf

