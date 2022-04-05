# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as pkgs with context %}

{%- set mode = 'latest' if pkgs.get('update_auto') else 'installed' %}

{%- set req_states = pkgs | traverse('_mas:required:states', []) %}
{%- set req_pkgs = pkgs | traverse('_mas:required:pkgs', []) %}

include:
  - tool_mas
{%- if req_states %}
{%-   for state in req_states %}
  - {{ state }}
{%-   endfor %}
{%- endif %}


{%- if req_pkgs %} {#- well, we get that one for free, probably unnecessary #}

Required packages for Mac App Store App installation are installed:
  pkg.{{ pkg_mode }}:
    - pkgs: {{ req_pkgs | json }}
    - require:
      - sls: tool-mas.package # seems like requiring the init.sls does not work
{%-   if req_states %}
{%-     for state in req_states %}
      - sls: {{ state }}
{%-     endfor %}
{%-   endif %}
{%- endif %}

{%- for user in pkgs.users | selectattr('pkgs.mas', 'defined') | selectattr('pkgs.mas.wanted', 'defined') %}
{%-   set req_states = user.pkgs.mas | traverse('required:states', []) %}
{%-   set req_pkgs =  user.pkgs.mas | traverse('required:pkgs', False) %}
{%-   for app in user.pkgs.mas.wanted %}

Wanted Mac App Store app '{{ app }}' is installed for user '{{ user.name }}':
  mas.{{ mode }}:
    - name: '{{ app }}'
    - user: {{ user.name }}
    - require:
      - mas setup is completed
{%-     if req_pkgs %}
      - Required packages for Mac App Store App installation are installed
{%-     endif %}
{%-     if req_states %}
{%-       for state in req_states %}
      - sls: {{ state }}
{%-       endfor %}
{%-     endif %}
{%-   endfor %}
{%- endfor %}
