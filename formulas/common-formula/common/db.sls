{% from "common/vars.sls" import mysql_root_password %}

mysql_pkgs:
  pkg.installed:
    - names:
      - mariadb
      - mariadb-server
      - MySQL-python

mariadb:
  service.running:
    - enable: True
    - require:
      - pkg: mysql_pkgs

/etc/my.cnf:
  file.managed:
    - template: jinja
    - source: salt://common/files/my.cnf
    - watch_in:
      - service: mariadb

# Won't copy dot file
# That's why is named users_my.cnf instead of .my.cnf
/root/.my.cnf:
  file.managed:
    - template: jinja
    - source: salt://common/files/users_my.cnf

mysql_root_user:
  mysql_user.present:
    - connection_host: localhost
    - connection_user: root
    - connection_pass: ''

    - host: localhost
    - name: root
    - password: {{ mysql_root_password }}
    - require:
      - service: mariadb

{% for host in ['localhost', grains.get('fqdn')] %}
mysql_delete_anonymous_user - {{ host }}:
  mysql_user.absent:
    - connection_host: localhost
    - connection_user: root
    - connection_pass: {{ mysql_root_password }}

    - host: {{ host }}
    - name: ''
    - require:
      - service: mariadb
      - mysql_user: mysql_root_user
{% endfor %}
