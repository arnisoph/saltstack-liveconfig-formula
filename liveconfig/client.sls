#!jinja|yaml

{% from 'liveconfig/defaults.yaml' import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('liveconfig:lookup')) %}

include:
  - liveconfig

{% if salt['grains.get']('os') in ['Ubuntu', 'Debian'] %}
  {% for p in datamap.client.pkgs|default({}) %}
    {% if 'debconf' in p %}
lc_client_debconf_{{ p.name }}:
  debconf:
    - set
    - name: {{ p.name }}
    - data:
        {% for k, v in p.debconf.items() %}{{ k }}: {{ v }}
        {% endfor %}
    {% endif %}
  {% endfor %}
{% endif %}

lc_client:
  pkg:
    - installed
    - pkgs:
{% for p in datamap.client.pkgs|default({}) %}
      - {{ p.name }}
{% endfor %}
  service:
    - {{ datamap.client.service.ensure|default('running') }}
    - name: {{ datamap.client.service.name|default('lcclient') }}
    - enable: {{ datamap.client.service.enable|default(True) }}

{% if 'main' in datamap.client.config.manage|default([]) %}
  {% set clc = datamap.client.config.main|default({}) %}
client_main_config:
  file:
    - managed
    - name: {{ clc.path|default('/etc/liveconfig/lcclient.conf') }}
    - source: {{ clc.template_path|default('salt://liveconfig/files/main') }}
    - user: {{ clc.user|default('root') }}
    - group: {{ clc_group|default('root') }}
    - mode: {{ clc.mode|default(600) }}
    - template: jinja
    - context:
      comp: client
    - watch_in:
      - service: lc_client
{% endif %}

activate_license:
  cmd:
    - run
    - name: LCLICENSEKEY='{{ salt['pillar.get']('liveconfig:lookup:licensekey', 'EK9N7-HFDPV-TEST') }}' /usr/sbin/lcclient --activate
    - user: root
    - unless: test -f /etc/liveconfig/lcclient.key
    - watch_in:
      - service: lc_client
