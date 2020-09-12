# commit hooks

[![Version: v1.5.0][version-badge]][changelog]
[![License: GPL v3][license-badge]][license]
[![CI status][ci-badge]][ci]
[![pre-commit][pre-commit-badge]][pre-commit]

Commit hooks using the [pre-commit](https://pre-commit.com) framework.

The hooks can be run client-side during development to give
early feedback about common errors, style consistency, and
standards enforcement.  They can also be run server-side on our
[gitolite](https://gitolite.com/gitolite/index.html) installation in
order to prevent problematic commits.

## Installation

### Client install

To install client-side, first [install the pre-commit package](https://pre-commit.com/#installation):

```bash
brew install pre-commit
```

or

```bash
pip install pre-commit
```

### Hook config

Add a `.pre-commit-config.yaml` to the top-level of the git repository.

```yaml
repos:
-   repo: https://github.com/bowdoincollege/noc-commit-hooks
    rev: <commit hash or tag>
    hooks:
    -   id: check-ipv6-case
    -   id: check-macaddr-case
        args: [ --fix ]
    -   id: check-dns-cname
    -   id: check-dns-config
    -   id: check-dhcp-config
```

### Install hook into repo

To install the hook into a specific git repo:

```bash
sapphire:~/dns/(master=)$ pre-commit install
pre-commit installed at .git/hooks/pre-commit
```

Or, create a git template and add the hook to it so any new/cloned repos
will have the hook added automatically.

```bash
git config --global init.templateDir ~/.git-template
pre-commit init-templatedir ~/.git-template
```

## Hooks

### `check-ipv6-case`

Check that all IPv6 literals are lower case.

The `-fix` and `-nofix` (default) options control whether the file
is modified.  Color output is enabled for terminal output, disabled
otherwise; it can be forced with `--color` or `--nocolor`.

### `check-macaddr-case`

Check that all MAC addresses are lower case.

The `-fix` and `-nofix` (default) options control whether the file
is modified.  Color output is enabled for terminal output, disabled
otherwise; it can be forced with `--color` or `--nocolor`.

### `check-dns-config`

Check bind DNS server configuration and zone files.

Runs `named-checkconf` to check [ISC bind
nameserver](https://www.isc.org/bind/) configuration files and zone
configurations.  The script expects the repository to be organized with
a top-level directory for each host.  The top-level `bind` directory is
for common files, typically symlinked from the other directories.

Requires `docker` installed on the local machine.

### `check-dhcp-config`

Check ISC DHCP server configuration files.

Runs `dhcpd -t` to check [ISC DHCP daemon](https://www.isc.org/dhcp/)
configuration files for any syntax errors.  The script expects a
top-level `include` directory for common files, and overwrites it with
any files in the top-level host directories before running the checks.

Requires `docker` installed on the local machine.

### `check-dhcphost-format`

Check ISC DHCP host entries match standard format.

Checks against a regex to match organizational standardized formatting
of DHCP host entries.  Uses fuzzy matching to indicate location of
possible errors.

### `check-dns-cname`

Check if any CNAME resource records point to an IP address.

The BIND parser (used by `check-dns-config`) does not fail if the
canonical name of a CNAME record looks like an IP address.  This is a
common mistake; even though it is valid syntax, it is almost never what
the user intended.

[version-badge]: https://img.shields.io/badge/version-1.5.0-blue.svg
[license-badge]: https://img.shields.io/badge/License-GPLv3-blue.svg
[ci-badge]: https://github.com/bowdoincollege/noc-commit-hooks/workflows/ci/badge.svg
[pre-commit-badge]: https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white
[changelog]: ./CHANGELOG.md
[license]: ./LICENSE
[ci]: https://github.com/bowdoincollege/noc-commit-hooks/actions?query=workflow%3Aci
[pre-commit]: https://pre-commit.com
