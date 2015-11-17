{% from "common/vars.sls" import ip %}

# Needed b/c of salt's sysctl state
/etc/sysctl.d/99-salt.conf:
  file.managed

kernel.hostname:
  sysctl.present:
    - value: controller

NetworkManager:
  service.dead:
    - disabled: True

network:
  service.running:
    - enable: True

hosts:
  host.present:
    - names:
      - controller
      - network
      - compute1
    - ip: {{ ip }}

yum-plugin-priorities:
  pkg.installed

openstack-icehouse:
  pkg.installed:
    - skip_verify: True
    - sources:
      - rdo-release: http://repos.fedorapeople.org/repos/openstack/openstack-icehouse/rdo-release-icehouse-3.noarch.rpm
    - require:
      - pkg: yum-plugin-priorities

openstack-utils:
  pkg.installed

python-pip:
  pkg.installed

# Won't persist
# Needs additional state to permanently change SELinux mode
permissive:
  selinux.mode:
    - persist: True

selinux_save_mode:
  file.replace:
    - name: /etc/selinux/config
    - pattern: ^SELINUX=.*
    - repl: SELINUX=permissive

include:
  - .msgqueue
  - .db
