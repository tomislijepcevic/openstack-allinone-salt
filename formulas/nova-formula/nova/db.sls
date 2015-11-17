{% from "nova/vars.sls" import NOVA_DBPASS %}
{% from 'common/macros.sls' import openstack_setup_db %}

{{ openstack_setup_db('nova', NOVA_DBPASS) }}
