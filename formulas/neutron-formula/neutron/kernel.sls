net.ipv4.ip_forward:
  sysctl.present:
    - config: /etc/sysctl.conf
    - value: 1

net.ipv4.conf.all.rp_filter:
  sysctl.present:
    - config: /etc/sysctl.conf
    - value: 0

net.ipv4.conf.default.rp_filter:
  sysctl.present:
    - config: /etc/sysctl.conf
    - value: 0
