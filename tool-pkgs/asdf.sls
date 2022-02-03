{%- from 'tool-pkgs/map.jinja' import pkgs -%}

{%- set pkg_mode = 'latest' if pkgs.get('update_auto')
                            and not grains['kernel'] == 'Darwin'
              else 'installed' -%}

{%- set req_states = pkgs | traverse('_asdf:required:states', []) -%}
{%- set req_pkgs = pkgs | traverse('_asdf:required:pkgs', []) -%}

include:
  - tool-asdf
{%- if req_states -%}
  {%- for state in req_states %}
  - {{ state }}
  {%- endfor %}
{%- endif %}

{%- if req_pkgs %}

Required packages for asdf plugin/version installation are installed:
  pkg.{{ pkg_mode }}:
    - pkgs: {{ req_pkgs | json }}
    - require:
      - sls: tool-asdf
  {%- if req_states %}
    {%- for state in req_states %}
      - sls: {{ state }}
    {%- endfor %}
  {%- endif %}
{%- endif %}

{%- for user in pkgs.users | selectattr('pkgs.asdf', 'defined') | selectattr('pkgs.asdf._wanted', 'defined') %}
  {%- for plugin, versions in user.pkgs.asdf._wanted.items() %}
    {%- if pkgs.get('update_auto') %}

asdf plugin {{ plugin }} is updated to latest version for user {{ user.name }}:
  asdf.plugin_latest:
    - name: {{ plugin }}
    - user: {{ user.name }}

    {%- endif %}
    {%- for version in versions %}
{#- versions are either defined or latest is automatically installed, so no mode for asdf necessary #}

Wanted package {{ plugin }} {{ version }} is installed with asdf for user '{{ user.name }}':
  asdf.version_installed:
    - name: {{ plugin }}
    - version: {{ version }}
    - user: {{ user.name }}
    - require:
      - sls: tool-asdf
      {%- if req_pkgs %}
      - Required packages for asdf plugin/version installation are installed
      {%- endif %}
      {%- if req_states %}
        {%- for state in req_states %}
      - sls: {{ state }}
        {%- endfor %}
      {%- endif %}
    {%- endfor %}
  {%- endfor %}
{%- endfor %}
