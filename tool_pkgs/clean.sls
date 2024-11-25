# vim: ft=sls

{#-
    *Meta-state*.

    Undoes everything performed in the ``tool_pkgs`` meta-state
    in reverse order.
#}

include:
  - .uv.clean
  - .pipx.clean
  - .mas.clean
  - .crates.clean
  - .asdf.clean
  - .packages.clean
