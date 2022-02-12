{%- if 'Darwin' == grains['kernel'] %}


{%- from 'tool-pkgs/map.jinja' import pkgs -%}
{%- set pkg_mode = 'latest' if pkgs.get('update_auto')
                            and not grains['kernel'] == 'Darwin'
              else 'installed' %}
{%- set mode = 'latest' if pkgs.get('update_auto') else 'installed' %}

{%- set req_states = pkgs | traverse('_mas:required:states', []) -%}
{%- set req_pkgs = pkgs | traverse('_mas:required:pkgs', []) -%}

include:
  - tool-mas
{%- if req_states -%}
  {%- for state in req_states %}
  - {{ state}}
  {%- endfor %}
{%- endif %}

{%- if req_pkgs %} {#- well, we get that one for free, probably not needed #}

Required packages for Mac App Store App installation are installed:
  pkg.{{ pkg_mode }}:
    - pkgs: {{ req_pkgs | json }}
    - require:
      - sls: tool-mas.package # seems like requiring the init.sls does not work
  {%- if req_states %}
    {%- for state in req_states %}
      - sls: {{ state }}
    {%- endfor %}
  {%- endif %}
{%- endif %}

{%- for user in pkgs.users | selectattr('pkgs.mas', 'defined') | selectattr('pkgs.mas.wanted', 'defined') %}
  {%- set req_states = user.pkgs.mas | traverse('required:states', []) %}
  {%- set req_pkgs =  user.pkgs.mas | traverse('required:pkgs', False) %}
  {%- for app in user.pkgs.mas.wanted %}

Wanted Mac App Store app '{{ app }}' is installed for user '{{ user.name }}':
  mas.{{ mode }}:
    - name: '{{ app }}'
    - user: {{ user.name }}
    - require:
      - sls: tool-mas.package
    {%- if req_pkgs %}
      - Required packages for Mac App Store App installation are installed
    {%- endif %}
    {%- if req_states %}
      {%- for state in req_states %}
      - sls: {{ state }}
      {%- endfor %}
    {%- endif %}
  {%- endfor %}
{%- endfor %}


{%- endif %}
