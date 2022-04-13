# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as pkgs with context %}


{%- for user in pkgs.users | selectattr('pkgs.asdf', 'defined') | selectattr('pkgs.asdf._wanted', 'defined') %}
{%-   for plugin, settings in user.pkgs.asdf._wanted.items() %}
{%-     for version in settings.versions %}

Wanted package {{ plugin }} {{ version }} is removed from asdf for user '{{ user.name }}':
  asdf.version_absent:
    - name: {{ plugin }}
    - version: {{ version }}
    - user: {{ user.name }}
    {%- endfor %}
  {%- endfor %}
{%- endfor %}
