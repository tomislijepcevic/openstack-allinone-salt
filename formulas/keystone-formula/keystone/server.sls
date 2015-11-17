{% from "keystone/vars.sls" import configs %}

openstack-keystone:
  pkg:
    - installed
  service.running:
    - enable: True
    - require:
      - pkg: openstack-keystone

python-keystoneclient:
  pkg.installed:
    - require:
      - pkg: openstack-keystone

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
      - cmd: keystone_manage_sync
      - service: openstack-keystone
{% endfor %}
{% endfor %}
{% endfor %}

keystone_manage_sync:
  cmd.run:
    - name: su -s /bin/sh -c "keystone-manage db_sync" keystone
    - unless: v=$(su -s /bin/sh -c "keystone-manage db_version" keystone) && [[ $v != 0 ]]
    - require:
      - cmd: openstack-config /etc/keystone/keystone.conf sql connection
      - pkg: openstack-keystone
    - require_in:
      - service: openstack-keystone

keystone_pki_setup:
  cmd.run:
    - name: >
        keystone-manage pki_setup
        --keystone-user keystone
        --keystone-group keystone
    - require:
      - cmd: keystone_manage_sync
    - require_in:
      - service: openstack-keystone

/etc/keystone/ssl:
  file.directory:
    - user: keystone
    - group: keystone
    - mode: 770
    - makedirs: True
    - recurse:
      - user
      - group
      - mode
    - require:
      - cmd: keystone_pki_setup
    - require_in:
      - service: openstack-keystone
