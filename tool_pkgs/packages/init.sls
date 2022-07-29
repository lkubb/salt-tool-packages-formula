# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as pkgs with context %}

{%- set mode = 'latest' if pkgs.get('update_auto')
                        and not grains['kernel'] == 'Darwin'
          else 'installed' %}

{%- set req_states = pkgs._system_pkgs.req_states %}
{%- set req_pkgs = pkgs._system_pkgs.req_pkgs %}
{%- set wanted = pkgs._system_pkgs.wanted %}

{%- if req_states %}
include:
{%-   for state in req_states %}
  - {{ state }}
{%-   endfor %}
{%- endif %}


{%- if req_pkgs %}

Required packages for system package installation are installed:
  pkg.{{ mode }}:
    - pkgs: {{ req_pkgs | json }}
{%-   if req_states %}
    - require:
{%-     for state in req_states %}
      - sls: {{ state }}
{%-     endfor %}
{%-   endif %}
{%- endif %}

{%- if wanted %}

Wanted system packages are installed:
  pkg.{{ mode }}:
    - pkgs: {{ wanted | json }}
{%-   if req_states or req_pkgs %}
    - require:
{%-     if req_pkgs %}
      - Required packages for system package installation are installed
{%-     endif %}
{%-     if req_states %}
{%-       for state in req_states %}
      - sls: {{ state }}
{%-       endfor %}
{%-     endif %}
{%-   endif %}
{%- endif %}
