{% from "keystone/vars.sls" import demo_user %}
#!/bin/sh

export OS_USERNAME='demo'
export OS_PASSWORD={{ demo_user.password }}
export OS_TENANT_NAME=demo
export OS_AUTH_URL=http://controller:5000/v2.0
