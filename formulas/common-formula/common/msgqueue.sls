touch_qpidd.conf:
  file.managed:
    - name: /etc/qpidd.conf

/etc/qpidd.conf:
  file.append:
    - text: auth-no
    - require:
      - pkg: qpid-cpp-server

qpidd:
  pkg.installed:
    - name: qpid-cpp-server
  service.running:
    - enable: True
    - watch:
      - file: /etc/qpidd.conf
    - require:
      - pkg: qpid-cpp-server
