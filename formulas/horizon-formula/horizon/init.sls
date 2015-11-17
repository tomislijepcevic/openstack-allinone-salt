{% from 'common/macros.sls' import openstack_config, openstack_setup_db, env with context %}

include:
  - common
  - keystone

horizon_packages:
  pkg.installed:
    - pkgs:
      - memcached
      - python-memcached
      - mod_wsgi
      - openstack-dashboard

horizon_settings_set_openstack_host:
  file.replace:
    - name: /etc/openstack-dashboard/local_settings
    - pattern: ^OPENSTACK_HOST.*
    - repl: OPENSTACK_HOST = "controller"

horizon_settings_set_allowed_hosts:
  file.replace:
    - name: /etc/openstack-dashboard/local_settings
    - pattern: ^ALLOWED_HOSTS.*
    - repl: ALLOWED_HOSTS = ['localhost', 'controller']

httpd_can_network_connect:
    selinux.boolean:
      - value: True
      - persist: True

horizon_services:
  service.running:
    - names:
      - httpd
      - memcached
    - enable: True
    - require:
      - pkg: horizon_packages
    - watch:
      - file: horizon_settings_set_openstack_host
      - file: horizon_settings_set_allowed_hosts

firewalld:
  service.running:
    - require:
      - service: horizon_services

{% for port in ['80/tcp', '443/tcp', '6080/tcp'] %}
firewalld open port - {{ port }}:
  cmd.run:
    - name: 'firewall-cmd --permanent --add-port={{ port }}'
    - unless: 'firewall-cmd --list-ports | egrep \s?{{ port }}\s?'
    - require:
      - service: firewalld
    - require_in:
      - firewall-cmd --reload
{% endfor %}

firewall-cmd --reload:
  cmd.run
