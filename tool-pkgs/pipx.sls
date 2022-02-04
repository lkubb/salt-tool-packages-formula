{%- from 'tool-pkgs/map.jinja' import pkgs -%}

{%- set pkg_mode = 'latest' if pkgs.get('update_auto')
                            and not grains['kernel'] == 'Darwin'
              else 'installed' %}
{%- set mode = 'latest' if pkgs.get('update_auto') else 'installed' %}

{%- set req_states = pkgs | traverse('_pipx:required:states', []) -%}
{%- set req_pkgs = pkgs | traverse('_pipx:required:pkgs', []) -%}

include:
  - tool-pipx
{%- if req_states -%}
  {%- for state in req_states %}
  - {{ state}}
  {%- endfor %}
{%- endif %}

{%- if req_pkgs %}

Required packages for pipx package installation are installed:
  pkg.{{ pkg_mode }}:
    - pkgs: {{ req_pkgs | json }}
    - require:
      - Pipx setup is completed
  {%- if req_states %}
    {%- for state in req_states %}
      - sls: {{ state }}
    {%- endfor %}
  {%- endif %}
{%- endif %}

{%- for user in pkgs.users | selectattr('pkgs.pipx', 'defined') | selectattr('pkgs.pipx.wanted', 'defined') %}
  {%- set req_states = user.pkgs.pipx | traverse('required:states', []) %}
  {%- set req_pkgs =  user.pkgs.pipx | traverse('required:pkgs', False) %}
  {%- for package in user.pkgs.pipx.wanted %}

Wanted pipx package '{{ package }}' is installed for user '{{ user.name }}':
  pipx.{{ mode }}:
    - name: {{ package }}
    - user: {{ user.name }}
    - require:
      - Pipx setup is completed
    {%- if req_pkgs %}
      - Required packages for pipx package installation are installed
    {%- endif %}
    {%- if req_states %}
      {%- for state in req_states %}
      - sls: {{ state }}
      {%- endfor %}
    {%- endif %}
  {%- endfor %}
{%- endfor %}
