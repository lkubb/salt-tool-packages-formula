# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as pkgs with context %}

{%- set mode = 'latest' if pkgs.get('update_auto') else 'installed' %}

{%- set req_states = pkgs | traverse('_crates:required:states', []) %}
{%- set req_pkgs = pkgs | traverse('_crates:required:pkgs', []) %}

include:
  - tool_rust
{%- if req_states %}
{%-   for state in req_states %}
  - {{ state }}
{%-   endfor %}
{%- endif %}


{%- if req_pkgs %}

Required packages for crates installation are installed:
  pkg.{{ pkg_mode }}:
    - pkgs: {{ req_pkgs | json }}
    - require:
      - Rust setup is completed
{%-   if req_states %}
{%-     for state in req_states %}
      - sls: {{ state }}
{%-     endfor %}
{%-   endif %}
{%- endif %}

{%- for user in pkgs.users | selectattr('pkgs.crates', 'defined') | selectattr('pkgs.crates._wanted', 'defined') %}

{%-   for crate, version in user.pkgs.crates._wanted.items() %}

Wanted crate '{{ crate }}' is installed for user '{{ user.name }}':
  cargo.{{ mode }}:
    - name: {{ crate }}
    - version: {{ version | first }}
    - user: {{ user.name }}
    - require:
      - Rust setup is completed
{%-     if req_pkgs %}
      - Required packages for crates installation are installed
{%-     endif %}
{%-     if req_states %}
{%-       for state in req_states %}
      - sls: {{ state }}
{%-       endfor %}
{%-     endif %}
{%-   endfor %}
{%- endfor %}