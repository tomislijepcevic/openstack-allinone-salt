{% from "glance/vars.sls" import GLANCE_DBPASS %}
{% from 'common/macros.sls' import openstack_setup_db %}

{{ openstack_setup_db('glance', GLANCE_DBPASS) }}
