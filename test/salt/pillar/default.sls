# vim: ft=yaml
# yamllint disable rule:comments-indentation
---
tool_global:
  users:
    user:
      completions: .completions
      configsync: true
      persistenv: .bash_profile
      rchook: .bashrc
      xdg: true
      pkgs:
        asdf:
          wanted:
            - direnv
            - golang: latest
            - python: 3.10.3
            - ruby
        crates:
          wanted:
            - flavours
            - rbw: 1.4.3
            - git: https://github.com/timepigeon/explainshell-cli
            - git:
                branch: release-please
                source: https://github.com/starship/starship
            - git:
                source: https://github.com/Peltoche/lsd
                tag: 0.21.0
            - git:
                rev: 5df94b5031d5b2ec0cb13424be600f418cbc0e07
                source: https://github.com/federico-terzi/espanso
        mas:
          wanted:
            - 747648890
            - Telegram
        pipx:
          required:
            - dotsync
          wanted:
            - poetry
        pkgs:
          required:
            - tool_git
          wanted:
            - coreutils
            - gawk
tool_pkgs:
  lookup:
    master: template-master
    # Just for testing purposes
    winner: lookup
    added_in_lookup: lookup_value

    pkg:
      name: pkgs
    paths:
      confdir: '.pkgs'
      conffile: 'config'
    rootgroup: root
  update_auto: false

  tofs:
    # The files_switch key serves as a selector for alternative
    # directories under the formula files directory. See TOFS pattern
    # doc for more info.
    # Note: Any value not evaluated by `config.get` will be used literally.
    # This can be used to set custom paths, as many levels deep as required.
    files_switch:
      - any/path/can/be/used/here
      - id
      - roles
      - osfinger
      - os
      - os_family
    # All aspects of path/file resolution are customisable using the options below.
    # This is unnecessary in most cases; there are sensible defaults.
    # Default path: salt://< path_prefix >/< dirs.files >/< dirs.default >
    #         I.e.: salt://tool_pkgs/files/default
    # path_prefix: template_alt
    # dirs:
    #   files: files_alt
    #   default: default_alt
    # The entries under `source_files` are prepended to the default source files
    # given for the state
    # source_files:
    #   tool-pkgs-config-file-file-managed:
    #     - 'example_alt.tmpl'
    #     - 'example_alt.tmpl.jinja'

  # Just for testing purposes
  winner: pillar
  added_in_pillar: pillar_value
