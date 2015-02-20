#!jinja|yaml

{% from 'liveconfig/defaults.yaml' import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('liveconfig:lookup')) %}

lcrepo: {#- TODO use apt formula #}
  pkgrepo:
    - {{ datamap.repo.ensure|default('managed') }}
    - name: {{ datamap.repo.debtype|default('deb') }} {{ datamap.repo.url }} {{ datamap.repo.dist|default('main') }}{% for c in datamap.repo.comps|default(['main']) %} {{ c }}{% endfor %}
    - file: /etc/apt/sources.list.d/liveconfig.list
  {% if datamap.repo.keyurl|default('https://www.liveconfig.com/liveconfig.key') is defined %}
    - key_url: {{ datamap.repo.keyurl|default('https://www.liveconfig.com/liveconfig.key') }}
  {% endif %}
