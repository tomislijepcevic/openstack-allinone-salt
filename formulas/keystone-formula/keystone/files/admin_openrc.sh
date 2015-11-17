{% from "keystone/vars.sls" import admin_user %}
#!/bin/sh

export OS_USERNAME='admin'
export OS_PASSWORD={{ admin_user.password }}
export OS_TENANT_NAME=admin
export OS_AUTH_URL=http://controller:5000/v2.0
