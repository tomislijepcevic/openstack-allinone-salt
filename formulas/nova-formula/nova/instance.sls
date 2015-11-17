{% from "glance/vars.sls" import cirros_image %}
{% from "keystone/vars.sls" import os_env_adminrc %}
{% from 'common/macros.sls' import env %}

include:
  - common
  - keystone
  - glance
  - neutron
  - cinder
  - horizon

demo_instance:
  cmd.run:
    - name: >
        nova boot
        --flavor 1
        --image {{ cirros_image.name }}
        --key-name demo-key
        --nic net-id=$(neutron net-list | awk '/ demo-net / {print $2}')
        demo-instance
    - onlyif: "[[ $(nova list | awk '/ ext-net / { print $2 }') == '' ]]"
    - env:
      {{ env(os_env_adminrc) }}
