{% from "glance/vars.sls" import cirros_image %}
{% from 'common/macros.sls' import env %}
{% from "keystone/vars.sls" import os_env_adminrc %}

glance_create_cirros_image:
  cmd.run:
    - name: >
        glance image-create --name={{ cirros_image.name }}
        --disk-format=qcow2
        --container-format=bare
        --is-public=true
        --copy-from {{ cirros_image.location }}
    - onlyif: >
        [[ $(glance image-list | awk '/ {{ cirros_image.name }} / {print $2}') == '' ]]
    - env:
        {{ env(os_env_adminrc) }}
    - require:
      - service: glance_services
