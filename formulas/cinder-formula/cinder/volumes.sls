{% from "cinder/vars.sls" import CINDER_VOLUME %}

pvcreate {{ CINDER_VOLUME }}:
  cmd.run:
    - unless: >
        [ -b {{ CINDER_VOLUME }} ]
        && pvs | grep {{ CINDER_VOLUME }}

vgcreate cinder-volumes {{ CINDER_VOLUME }}:
  cmd.run:
    - unless: vgs | grep cinder-volumes
    - require:
      - cmd: 'pvcreate {{ CINDER_VOLUME }}'

/etc/tgt/targets.conf:
  file.prepend:
    - text: include /etc/cinder/volumes/*
    - require:
      - cmd: 'vgcreate cinder-volumes {{ CINDER_VOLUME }}'
