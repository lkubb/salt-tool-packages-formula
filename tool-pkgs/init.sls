{%- from 'tool-pkgs/map.jinja' import pkgs, managers -%}

include:
{%- if pkgs._system_pkgs.wanted or pkgs._system_pkgs.req_states or pkgs._system_pkgs.req_pkgs %}
  - .packages
{%- endif %}
{%- for manager in managers %}
  {%- if pkgs.users | selectattr('pkgs.' ~ manager, 'defined') | list %}
  - .{{ manager }}
  {%- endif %}
{%- endfor %}
