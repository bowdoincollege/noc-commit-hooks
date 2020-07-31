# commit hooks

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
pip install pre-commit
```

or

```bash
brew install pre-commit
```

### Hook config

Add a `.pre-commit-config.yaml` to the toplevel of the git repository.

```yaml
repos:
-   repo: https://github.com/bowdoincollege/noc-commit-hooks
    rev: <commit hash or tag>
    hooks:
    -   id: check-ipv6-case
    -   id: check-dns-config
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

Check that all IPv6 literals are capitalized.

The `-fix` and `-nofix` (default) options control whether the file is
modified.

### `check-dns-config`

Check bind DNS server configuration and zone files

Runs `named-checkconf` to check [ISC bind
nameserver](https://www.isc.org/bind/) configuration files and zone
configurations.  The script expects the repository to be organized with
a toplevel directory for each host.  The toplevel `bind` directory is
for common files, typically symlinked from the other directories.

Requires `docker` installed on the local machine.
