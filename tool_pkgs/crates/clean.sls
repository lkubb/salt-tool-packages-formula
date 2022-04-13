# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as pkgs with context %}


{%- for user in pkgs.users | selectattr('pkgs.crates', 'defined') | selectattr('pkgs.crates._wanted', 'defined') %}
{%-   for crate, settings in user.pkgs.crates._wanted.items() %}
{%-     if settings.git %}

Cannot remove crate '{{ crate }}' for user '{{ user.name }}':
  test.show_notification:
    - text: Currently cannot automatically remove crates installed from other sources than `crates.io`.

{%-     else %}

Wanted crate '{{ crate }}' is removed for user '{{ user.name }}':
  cargo.absent:
    - name: {{ crate }}
    - user: {{ user.name }}
{%-     endif %}
{%-   endfor %}
{%- endfor %}
