#!jinja|yaml

{% from 'liveconfig/defaults.yaml' import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('liveconfig:lookup')) %}

include:
  - liveconfig

{% if datamap.lua.manage|default(False) %}
lua_dir:
  file:
    - recurse
    - name: {{ datamap.lua.path }}
    - source: {{ datamap.lua.source|default('salt://liveconfig/files/lua') }}
    - user: root
{% endif %}
