# vim: ft=sls

{#-
    *Meta-state*.

    Performs all operations described in this formula according to the specified configuration.
#}

include:
  - .packages
  - .asdf
  - .crates
  - .mas
  - .pipx
  - .uv
