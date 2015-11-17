{% from "cinder/vars.sls" import CINDER_DBPASS %}
{% from 'common/macros.sls' import openstack_setup_db %}

{{ openstack_setup_db('cinder', CINDER_DBPASS) }}
