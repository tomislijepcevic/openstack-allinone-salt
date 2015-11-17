{% from "keystone/vars.sls" import os_env_adminrc %}
{% from 'common/macros.sls' import env %}

/root/id_rsa.pub:
  file.managed:
    - source: salt://nova/files/id_rsa.pub

demo-keypair:
  cmd.run:
    - name: >
        nova keypair-add
        --pub-key /root/id_rsa.pub
        demo-key
    - onlyif: "[[ $(nova keypair-list | awk '/ demo-key / { print $2 }') == '' ]]"
    - env:
      {{ env(os_env_adminrc) }}
    - require:
      - file: /root/id_rsa.pub
