{% from "keystone/vars.sls" import KEYSTONE_DBPASS %}
{% from 'common/macros.sls' import openstack_setup_db %}

{{ openstack_setup_db('keystone', KEYSTONE_DBPASS) }}
