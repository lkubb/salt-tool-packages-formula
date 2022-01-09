# Packages Formula
Installs packages with different package managers that don't need further configuration. Goes well with `tool-dotsync` to sync dotfiles.

**Note**: Currently, with the exception of `asdf` (which is a version manager after all) and `crates`, this formula will always install the latest version of the package.

## Usage
Applying `tool-pkgs` will make sure all requested packages are installed as specified.

## Configuration
### Pillar
#### General `tool` architecture
Since installing user environments is not the primary use case for saltstack, the architecture is currently a bit awkward. All `tool` formulas assume running as root. There are three scopes of configuration:
1. per-user `tool`-specific
  > e.g. generally force usage of XDG dirs in `tool` formulas for this user
2. per-user formula-specific
  > e.g. setup this tool with the following configuration values for this user
3. global formula-specific (All formulas will accept `defaults` for `users:username:formula` default values in this scope as well.)
  > e.g. setup system-wide configuration files like this

**3** goes into `tool:formula` (e.g. `tool:git`). Both user scopes (**1**+**2**) are mixed per user in `users`. `users` can be defined in `tool:users` and/or `tool:formula:users`, the latter taking precedence. (**1**) is namespaced directly under `username`, (**2**) is namespaced under `username: {formula: {}}`.

```yaml
tool:
######### user-scope 1+2 #########
  users:                         #
    username:                    #
      xdg: true                  #
      dotconfig: true            #
      formula:                   #
        config: value            #
####### user-scope 1+2 end #######
  formula:
    formulaspecificstuff:
      conf: val
    defaults:
      yetanotherconfig: somevalue
######### user-scope 1+2 #########
    users:                       #
      username:                  #
        xdg: false               #
        formula:                 #
          otherconfig: otherval  #
####### user-scope 1+2 end #######
```

#### User-specific
The following shows an example of `tool-pkgs` pillar configuration. Namespace it to `tool:users` and/or `tool:pkgs:users`.
```yaml
user:
  pkgs:
    pkgs:                       # System package manager packages.
      wanted:                   # The system's default package manager installs packages globally, therefore they
        - dnsutil               # will be accumulated for all users. Stick to tool:pkgs:defaults to keep it simple
    pipx:                       # Install python applications/libs with a cli interface globally inside
      wanted:                   # their dedicated venv, without depending on the default python version.
        - cowsay
      required:                 # requisites
        pkgs:                   # Those -> system packages <- will be installed first. This works for
          - pipx                # every package manager listed here.
        states:                 # Those -> states <- will be required before installing. This works for
          - dotsync             # every package manager listed here.
    mas:                        # Mac App Store apps are best specified by ID.
      wanted:
        - 747648890             # Mac App Store apps are best specified by ID. You can list a name as well,
       #- Telegram              # but the installation might not be deterministic (first search result).
    crates:                     # Install crates with cargo. Make sure you add the installation path to $path.
      wanted:                   # By default, they will be installed in CARGO_INSTALL_ROOT/bin > CARGO_HOME/bin.
        - flavours
        - rbw: '1.4.1'          # Installing a specific version is possible in Cargo.
    asdf:                       # asdf is a version manager, so here it is easy to specify package version.
      wanted:
        - direnv                # Without version, latest will be installed by default.
        - golang: latest        # You can specify latest explicitly,
        - python: '3.10.1'      # as well as a specific version.
        - ruby:                 # as well as a list of versions
          - '3.1.0'
          - '2.7.5'             # Most script language packages depend on the version, so they are best installed
                                # by the asdf plugin via a default-* file (eg default-gems) that you can sync
                                # via your dotfiles. (ruby/nodejs/pips) pipx is an exception since it isolates
                                # the application's environment inside a venv
```

#### Formula-specific
```yaml
tool:
  pkgs:
    update_auto: True           # keep the packages updated to their latest version on subsequent
                                # runs (system packages on MacOS are kept up to date by brew anyways)
    defaults:                   # Default formula configuration for all users.
      pkgs:                     # Package manager packages.
        wanted:                 # Those will be installed with the system's default package manager.
          - coreutils           # Since they will be installed globally, all packages for all users
          - gawk                # will be accumulated. It's best you specify them here once.
        required:
          states:
            - tool-git
      pipx:
        wanted:
          - poetry              # Packages from defaults will be merged with user-specific ones.
```

## Todo
- make installation of specific version possible, if the underlying manager supports it

## References
- https://github.com/saltstack-formulas/packages-formula
