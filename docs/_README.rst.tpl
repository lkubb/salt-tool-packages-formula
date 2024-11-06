.. _readme:

Packages Formula
================

Installs packages with different package managers that don't need further configuration. Goes well with ``tool_dotsync`` to sync dotfiles.

**Note**: Currently, with the exception of `asdf` (which is a version manager after all) and `crates`, this formula will always install the latest version of the package.

.. contents:: **Table of Contents**
   :depth: 1

Usage
-----
Applying ``tool_pkgs`` will make sure all requested packages are installed as specified.

Configuration
-------------

This formula
~~~~~~~~~~~~
The general configuration structure is in line with all other formulae from the `tool` suite, for details see :ref:`toolsuite`. An example pillar is provided, see :ref:`pillar.example`. Note that you do not need to specify everything by pillar. Often, it's much easier and less resource-heavy to use the ``parameters/<grain>/<value>.yaml`` files for non-sensitive settings. The underlying logic is explained in :ref:`map.jinja`.

User-specific
^^^^^^^^^^^^^
The following shows an example of ``tool_pkgs`` per-user configuration. If provided by pillar, namespace it to ``tool_global:users`` and/or ``tool_pkgs:users``. For the ``parameters`` YAML file variant, it needs to be nested under a ``values`` parent key. The YAML files are expected to be found in

1. ``salt://tool_pkgs/parameters/<grain>/<value>.yaml`` or
2. ``salt://tool_global/parameters/<grain>/<value>.yaml``.

.. code-block:: yaml

  user:

      # Persist environment variables used by this formula for this
      # user to this file (will be appended to a file relative to $HOME)
    persistenv: '.config/zsh/zshenv'

      # Add runcom hooks specific to this formula to this file
      # for this user (will be appended to a file relative to $HOME)
    rchook: '.config/zsh/zshrc'

      # This user's configuration for this formula. Will be overridden by
      # user-specific configuration in `tool_pkgs:users`.
      # Set this to `false` to disable configuration for this user.
    pkgs:
        # asdf is a version manager, so here it is easy to specify package version.
      asdf:
        wanted:
            # Without version, latest will be installed by default.
          - direnv
            # You can specify latest explicitly,
          - golang: latest
            # as well as a specific version.
          - python: 3.10.3
            # Most script language packages depend on the version, so they are best installed
            # by the asdf plugin via a default-* file (eg default-gems) that you can sync
            # via your dotfiles. (ruby/nodejs/pips) pipx is an exception since it isolates
            # the application's environment inside a venv
          - ruby
      crates:
        # Install crates with cargo. Make sure you add the installation path to $path.
        # By default, they will be installed in CARGO_INSTALL_ROOT/bin > CARGO_HOME/bin.
        wanted:
              # Install the latest version from crates.io.
          - flavours
              # Install a specific version from crates.io.
          - rbw: 1.4.3
              # Install from HEAD of the default branch.
          - git: https://github.com/timepigeon/explainshell-cli
              # Install from HEAD of a specific branch.
          - git:
              branch: release-please
              source: https://github.com/starship/starship
              # Install from a tagged commit.
          - git:
              source: https://github.com/Peltoche/lsd
              tag: 0.21.0
              # Install from a specific commit.
          - git:
              rev: 5df94b5031d5b2ec0cb13424be600f418cbc0e07
              source: https://github.com/federico-terzi/espanso
      mas:
        wanted:
            # Mac App Store apps are best specified by ID.
          - 747648890
         #- Telegram
        # Install python applications/libs with a cli interface globally inside
        # their dedicated venv, without depending on the default python version.
      pipx:
          # Those -> states <- will be required before installing. Works for all managers.
        required:
          - dotsync
        wanted:
          - poetry
        # package manager packages
      pkgs:
          # Those -> states <- will be required before installing.
        required:
          - tool_git
          # Those will be installed with the system's default package manager.
          # Since they will be installed globally, all packages for all users
          # will be accumulated.
        wanted:
          - coreutils
          - gawk

Formula-specific
^^^^^^^^^^^^^^^^

.. code-block:: yaml

  tool_pkgs:
      # keep the packages updated to their latest version on subsequent
      # runs (system packages on MacOS are kept up to date by brew anyways)
    update_auto: false

      # Default formula configuration for all users.
      # Packages from defaults will be merged with user-specific ones.
    defaults:
      pkgs: default value for all users

<INSERT_STATES>

Development
-----------

Contributing to this repo
~~~~~~~~~~~~~~~~~~~~~~~~~

Commit messages
^^^^^^^^^^^^^^^

Commit message formatting is significant.

Please see `How to contribute <https://github.com/saltstack-formulas/.github/blob/master/CONTRIBUTING.rst>`_ for more details.

pre-commit
^^^^^^^^^^

`pre-commit <https://pre-commit.com/>`_ is configured for this formula, which you may optionally use to ease the steps involved in submitting your changes.
First install  the ``pre-commit`` package manager using the appropriate `method <https://pre-commit.com/#installation>`_, then run ``bin/install-hooks`` and
now ``pre-commit`` will run automatically on each ``git commit``.

.. code-block:: console

  $ bin/install-hooks
  pre-commit installed at .git/hooks/pre-commit
  pre-commit installed at .git/hooks/commit-msg

State documentation
~~~~~~~~~~~~~~~~~~~
There is a script that semi-autodocuments available states: ``bin/slsdoc``.

If a ``.sls`` file begins with a Jinja comment, it will dump that into the docs. It can be configured differently depending on the formula. See the script source code for details currently.

This means if you feel a state should be documented, make sure to write a comment explaining it.

Testing
~~~~~~~

Linux testing is done with ``kitchen-salt``.

Requirements
^^^^^^^^^^^^

* Ruby
* Docker

.. code-block:: bash

  $ gem install bundler
  $ bundle install
  $ bin/kitchen test [platform]

Where ``[platform]`` is the platform name defined in ``kitchen.yml``,
e.g. ``debian-9-2019-2-py3``.

``bin/kitchen converge``
^^^^^^^^^^^^^^^^^^^^^^^^

Creates the docker instance and runs the ``tool_pkgs`` main state, ready for testing.

``bin/kitchen verify``
^^^^^^^^^^^^^^^^^^^^^^

Runs the ``inspec`` tests on the actual instance.

``bin/kitchen destroy``
^^^^^^^^^^^^^^^^^^^^^^^

Removes the docker instance.

``bin/kitchen test``
^^^^^^^^^^^^^^^^^^^^

Runs all of the stages above in one go: i.e. ``destroy`` + ``converge`` + ``verify`` + ``destroy``.

``bin/kitchen login``
^^^^^^^^^^^^^^^^^^^^^

Gives you SSH access to the instance for manual testing.

Todo
----
* make installation of specific version possible, if the underlying manager supports it
* add ``absent`` configuration as well

References
----------
* https://github.com/saltstack-formulas/packages-formula
