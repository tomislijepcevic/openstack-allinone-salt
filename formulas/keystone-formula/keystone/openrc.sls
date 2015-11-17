# Tilde expansion is not avaiable
# Only absolute paths are allowed
/root/admin_openrc.sh:
  file.managed:
    - source: salt://keystone/files/admin_openrc.sh
    - template: jinja

/root/demo_openrc.sh:
  file.managed:
    - source: salt://keystone/files/demo_openrc.sh
    - template: jinja
