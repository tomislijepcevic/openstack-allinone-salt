{% import "common/vars.sls" as common with context %}

{% macro openstack_config(configs, requiredPkg) %}
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
      - pkg: '{{ requiredPkg }}'
{% endfor %}
{% endfor %}
{% endfor %}
{%- endmacro %}

{% macro openstack_setup_db(project, password) %}
  {% for host in ['localhost', '\'%\''] %}
{{ project }}_user - {{ host }}:
  mysql_user.present:
    - name: {{ project }}
    - password: {{ password }}
    - host: {{ host }}
    - connection_host: localhost
    - connection_user: root
    - connection_pass: {{ common.mysql_root_password }}
    - require:
      - service: mariadb
  {% endfor %}

{{ project }}_database:
  mysql_database.present:
    - name: {{ project }}
    - connection_host: localhost
    - connection_user: root
    - connection_pass: {{ common.mysql_root_password }}
    - require:
      - mysql_user : {{ project }}

  {% for host in ['localhost', '\'%\''] %}
{{ project }}_privileges - {{ host }}:
  mysql_grants.present:
    - grant: all privileges
    - host: {{ host }}
    - database: {{ project }}.*
    - user: {{ project }}
    - connection_host: localhost
    - connection_user: root
    - connection_pass: {{ common.mysql_root_password }}
    - require:
      - mysql_database : {{ project }}
  {% endfor %}
{%- endmacro %}

{% macro env(envDict) %}
  {% for key, value in envDict.iteritems() %}
        - '{{ key }}': '{{ value }}'
  {% endfor %}
{%- endmacro %}
