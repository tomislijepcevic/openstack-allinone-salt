{% from "neutron/vars.sls" import NEUTRON_DBPASS %}
{% from 'common/macros.sls' import openstack_setup_db %}

{{ openstack_setup_db('neutron', NEUTRON_DBPASS) }}
