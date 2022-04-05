# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as pkgs with context %}


{%- for user in pkgs.users | selectattr('pkgs.crates', 'defined') | selectattr('pkgs.crates._wanted', 'defined') %}

{%-   for crate, version in user.pkgs.crates._wanted.items() %}

Wanted crate '{{ crate }}' is removed for user '{{ user.name }}':
  cargo.absent:
    - name: {{ crate }}
    - version: {{ version | first }}
    - user: {{ user.name }}
{%-   endfor %}
{%- endfor %}
