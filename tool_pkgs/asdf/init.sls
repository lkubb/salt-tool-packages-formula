# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as pkgs with context %}

{%- set mode = "latest" if pkgs.get("update_auto") else "installed" %}

{%- set req_states = pkgs | traverse("_asdf:required:states", []) %}
{%- set req_pkgs = pkgs | traverse("_asdf:required:pkgs", []) %}

{%- if pkgs.users | selectattr("pkgs.asdf", "defined") | selectattr("pkgs.asdf._wanted", "defined") | list %}

include:
  - tool_asdf
{%-   if req_states %}
{%-     for state in req_states %}
  - {{ state }}
{%-     endfor %}
{%-   endif %}
{%- endif %}

{%- if req_pkgs %}

Required packages for asdf plugin/version installation are installed:
  pkg.{{ pkg_mode }}:
    - pkgs: {{ req_pkgs | json }}
    - require:
      - asdf setup is completed
{%-   if req_states %}
{%-     for state in req_states %}
      - sls: {{ state }}
{%-     endfor %}
{%-   endif %}
{%- endif %}


{%- for user in pkgs.users | selectattr("pkgs.asdf", "defined") | selectattr("pkgs.asdf._wanted", "defined") %}
{%-   for plugin, settings in user.pkgs.asdf._wanted.items() %}
{%-     if pkgs.get("update_auto") %}

asdf plugin {{ plugin }} is updated to latest version for user {{ user.name }}:
  asdf.plugin_latest:
    - name: {{ plugin }}
    - user: {{ user.name }}

{%-     endif %}
{%-     for version in settings.versions %}
{#-       versions are either defined or latest is automatically installed, so no mode for asdf necessary #}

Wanted package {{ plugin }} {{ version }} is installed with asdf for user '{{ user.name }}':
  asdf.version_installed:
    - name: {{ plugin }}
    - version: {{ version }}
    - user: {{ user.name }}
    - require:
      - asdf setup is completed
{%-       if req_pkgs %}
      - Required packages for asdf plugin/version installation are installed
{%-       endif %}
{%-       if req_states %}
{%-         for state in req_states %}
      - sls: {{ state }}
{%-         endfor %}
{%-       endif %}
{%-     endfor %}
{%-   endfor %}
{%- endfor %}
