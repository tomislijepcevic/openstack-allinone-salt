{% set openstack = pillar.get('openstack', {}) %}
{% set common = openstack.get('common', {}) %}

{% set mysql_root_password =  common.get('mysql_root_password', 'foobar') %}
{% set ip =  common.get('ip', grains.get('ip_interfaces:eth0')[0] ) %}
