# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as pkgs with context %}


{%- for user in pkgs.users | selectattr("pkgs.pipx", "defined") | selectattr("pkgs.pipx.wanted", "defined") %}
{%-   for package in user.pkgs.pipx.wanted %}

Wanted pipx package '{{ package }}' is installed for user '{{ user.name }}':
  pipx.absent:
    - name: {{ package }}
    - user: {{ user.name }}
{%-   endfor %}
{%- endfor %}
