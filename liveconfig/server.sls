#!jinja|yaml

{% from 'liveconfig/defaults.yaml' import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('liveconfig:lookup')) %}

include:
  - liveconfig

{% if salt['grains.get']('os') in ['Ubuntu', 'Debian'] %}
  {% for p in datamap.server.pkgs|default({}) %}
    {% if 'debconf' in p %}
lc_server_debconf_{{ p.name }}:
  debconf:
    - set
    - name: {{ p.name }}
    - data:
        {% for k, v in p.debconf.items() %}{{ k }}: {{ v }}
        {% endfor %}
    {% endif %}
  {% endfor %}
{% endif %}

lc_server:
  pkg:
    - installed
    - pkgs:
{% for p in datamap.server.pkgs|default({}) %}
      - {{ p.name }}
{% endfor %}
  service:
    - {{ datamap.server.service.ensure|default('running') }}
    - name: {{ datamap.server.service.name|default('liveconfig') }}
    - enable: {{ datamap.server.service.enable|default(True) }}

db_sqlite:
  file:
    - {{ datamap.server.sqlite_db.ensure|default('absent') }}
    - name: {{ datamap.server.sqlite_db.path|default('/var/lib/liveconfig/liveconfig.db') }}

{% if 'main' in datamap.server.config.manage|default([]) %}
  {% set clc = datamap.server.config.main|default({}) %}
server_main_config:
  file:
    - managed
    - name: {{ clc.path|default('/etc/liveconfig/liveconfig.conf') }}
    - source: {{ clc.template_path|default('salt://liveconfig/files/main') }}
    - user: {{ clc.user|default('root') }}
    - group: {{ clc_group|default('root') }}
    - mode: {{ clc.mode|default(600) }}
    - template: jinja
    - context:
      comp: server
    - watch_in:
      - service: lc_server
{% endif %}

activate_license:
  cmd:
    - run
    - name: LCLICENSEKEY='{{ salt['pillar.get']('liveconfig:lookup:licensekey', 'EK9N7-HFDPV-TEST') }}' /usr/sbin/liveconfig --activate
    - user: root
    - unless: test -f /etc/liveconfig/liveconfig.key
    - watch_in:
      - service: lc_server

{% if datamap.lua.manage|default(False) %}
lua_dir:
  file:
    - recurse
    - name: {{ datamap.lua.path }}
    - source: {{ datamap.lua.source|default('salt://liveconfig/files/lua') }}
    - user: root
    - watch_in:
      - service: lc_server
{% endif %}
