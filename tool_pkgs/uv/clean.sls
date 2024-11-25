# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as pkgs with context %}


{%- for package, config in (pkgs | traverse("uv:wanted", {})).items() %}

Wanted uv package '{{ package }}' is removed globally:
  uv_tool.absent:
    - name: {{ package }}
    - system: true
    - require:
      - uv setup is completed
{%- endfor %}

{%- for user in pkgs.users | selectattr("pkgs.uv", "defined") | selectattr("pkgs.uv.wanted", "defined") %}
{%-   for package in user.pkgs.uv.wanted %}

Wanted uv package '{{ package }}' is removed for user '{{ user.name }}':
  uv_tool.absent:
    - name: {{ package }}
    - user: {{ user.name }}
{%-   endfor %}
{%- endfor %}
