# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as pkgs with context %}

{%- set upgrade = not not pkgs.get("update_auto") %}

{%- set req_states = pkgs | traverse("_uv:required:states", []) %}
{%- set req_pkgs = pkgs | traverse("_uv:required:pkgs", []) %}

include:
  - tool_uv
{%- if req_states %}
{%-   for state in req_states %}
  - {{ state }}
{%-   endfor %}
{%- endif %}


{%- if req_pkgs %}

Required packages for uv package installation are installed:
  pkg.{{ pkg_mode }}:
    - pkgs: {{ req_pkgs | json }}
    - require:
      - uv setup is completed
{%-   if req_states %}
{%-     for state in req_states %}
      - sls: {{ state }}
{%-     endfor %}
{%-   endif %}
{%- endif %}

{%- set global_req_states = pkgs | traverse("uv:required:states", []) %}
{%- set global_req_pkgs =  pkgs | traverse("uv:required:pkgs", false) %}

{%- for package in (pkgs | traverse("uv:wanted", [])) %}
{%-   if package is mapping %}
{%-     set tool = package | first %}
{%-     set config = package.values() | first %}
{%-   else %}
{%-     set tool = package %}
{%-     set config = {} %}
{%-   endif %}

Wanted uv package '{{ tool }}' is installed globally:
  uv_tool.installed:
    - name: {{ tool }}
    - system: true
    - upgrade: {{ upgrade }}
{%-   for param, val in config.items() %}
    - {{ param }}: {{ val | json }}
{%-   endfor %}
    - require:
      - uv setup is completed
{%-   if global_req_pkgs %}
      - Required packages for uv package installation are installed
{%-   endif %}
{%-   if global_req_states %}
{%-     for state in global_req_states %}
      - sls: {{ state }}
{%-     endfor %}
{%-   endif %}
{%- endfor %}

{%- for user in pkgs.users | selectattr("pkgs.uv", "defined") | selectattr("pkgs.uv.wanted", "defined") %}
{%-   set req_states = user.pkgs.uv | traverse("required:states", []) %}
{%-   set req_pkgs =  user.pkgs.uv | traverse("required:pkgs", false) %}
{%-   for package in user.pkgs.uv.wanted %}
{%-     if package is mapping %}
{%-       set tool = package | first %}
{%-       set config = package.values() | first %}
{%-     else %}
{%-       set tool = package %}
{%-       set config = {} %}
{%-     endif %}

Wanted uv package '{{ tool }}' is installed for user '{{ user.name }}':
  uv_tool.installed:
    - name: {{ tool }}
    - user: {{ user.name }}
    - upgrade: {{ upgrade }}
{%-     for param, val in config.items() %}
    - {{ param }}: {{ val | json }}
{%-     endfor %}
    - require:
      - uv setup is completed
{%-     if req_pkgs %}
      - Required packages for uv package installation are installed
{%-     endif %}
{%-     if req_states %}
{%-       for state in req_states %}
      - sls: {{ state }}
{%-       endfor %}
{%-     endif %}
{%-   endfor %}
{%- endfor %}
