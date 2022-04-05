# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as pkgs with context %}

{%- set wanted = pkgs._system_pkgs.wanted -%}

{%- if wanted %}

Wanted system packages are absent:
  pkg.absent:
    - pkgs: {{ wanted | json }}
{%- endif %}
