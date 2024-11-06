# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as pkgs with context %}


{%- for user in pkgs.users | selectattr("pkgs.mas", "defined") | selectattr("pkgs.mas.wanted", "defined") %}
{%-   for app in user.pkgs.mas.wanted %}

Wanted Mac App Store app '{{ app }}' is removed for user '{{ user.name }}':
  mas.absent:
    - name: '{{ app }}'
    - user: {{ user.name }}
{%-   endfor %}
{%- endfor %}
