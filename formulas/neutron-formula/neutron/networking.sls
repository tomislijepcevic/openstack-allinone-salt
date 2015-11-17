{% from "neutron/vars.sls" import ext_net, demo_net %}
{% from "keystone/vars.sls" import os_env_adminrc %}
{% from 'common/macros.sls' import env %}

neutron_ext-net:
  cmd.run:
    - name: >
        neutron net-create
        ext-net
        --shared
        --router:external=True
    - onlyif: "[[ $(neutron net-list | awk '/ ext-net / { print $2 }') == '' ]]"
    - env:
      {{ env(os_env_adminrc) }}
    - require:
      - service: neutron-server

neutron_ext-subnet:
  cmd.run:
    - name: >
        neutron subnet-create ext-net
        --name ext-subnet
        --allocation-pool start={{ ext_net.pool.start }},end={{ ext_net.pool.end }}
        --disable-dhcp
        --gateway {{ ext_net.gateway }}
        {{ ext_net.cidr }}
    - onlyif: "[[ $(neutron subnet-list | awk '/ ext-subnet / { print $2 }') == '' ]]"
    - env:
      {{ env(os_env_adminrc) }}
    - require:
      - service: neutron-server
      - cmd: neutron_ext-net

neutron_demo-net:
  cmd.run:
    - name: neutron net-create demo-net
    - onlyif: "[[ $(neutron net-list | awk '/ demo-net / { print $2 }') == '' ]]"
    - env:
      {{ env(os_env_adminrc) }}
    - require:
      - service: neutron-server

neutron_demo-subnet:
  cmd.run:
    - name: >
        neutron subnet-create demo-net
        --name demo-subnet
        --gateway {{ demo_net.gateway }}
        --dns-nameserver 8.8.8.8
        {{ demo_net.cidr }}
    - onlyif: "[[ $(neutron subnet-list | awk '/ demo-subnet / { print $2 }') == '' ]]"
    - env:
      {{ env(os_env_adminrc) }}
    - require:
      - service: neutron-server
      - cmd: neutron_demo-net

neutron_demo-router:
  cmd.run:
    - name: neutron router-create demo-router
    - onlyif: "[[ $(neutron router-list | awk '/ demo-router / { print $2 }') == '' ]]"
    - env:
      {{ env(os_env_adminrc) }}
    - require:
      - service: neutron-server

neutron_demo-router_interface:
  cmd.run:
    - name: neutron router-interface-add demo-router demo-subnet
    - env:
      {{ env(os_env_adminrc) }}
    - unless: >
        neutron router-port-list demo-router |
        grep $(neutron subnet-list | awk '/ demo-subnet / { print $2 }')
    - require:
      - cmd: neutron_demo-router
      - cmd: neutron_demo-subnet

neutron_demo-router_gateway:
  cmd.run:
    - name: neutron router-gateway-set demo-router ext-net
    - unless: >
        neutron router-port-list demo-router |
        grep $(neutron subnet-list | awk '/ ext-subnet / { print $2 }')
    - env:
      {{ env(os_env_adminrc) }}
    - require:
      - cmd: neutron_demo-router
      - cmd: neutron_ext-net
