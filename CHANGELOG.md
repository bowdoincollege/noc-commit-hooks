# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [unreleased]

### Changed

- sort hooks in README alphabetically and by type
- provide separate `.pre-commit.config.yaml` examples for each hook type

## [v1.5.0] - 2020-09-12

### Added

- new `check-dns-cname` hook to check CNAME is not an IP

### Changed

- move shared testing code to separate module
- much improved `check-dhcphost-format` fuzzy matching colorization output
- increased `check_dhcphost_format` fuzzy matching error threshold
- updated perl build and test tooling

## [v1.4.0] - 2020-08-25

### Added

- new `--color` and `--nocolor` options to perl hooks to override default
  (color output if connected to a terminal).
- moved perl hooks from `script` to `perl`
- perl testing and code coverage tooling
- GitHub workflows for perl tests
- Changelog

### Fixed

- perl hooks now exit 1 even if file is fixed (`--fix` option)
- perl hooks did not find errors on a line with multiple IPv6/MAC addresses
  if only the second address had an error
- line number in STDERR output was not resetting between files for multiple files
  on the commandline
- yaml cleanup (and associated pre-commit hooks)

## [v1.3.0] - 2020-08-20

### Added

- new `check_dhcphost_format` hook to validate organization-specific formatting rules
  for DHCP host entries
- This script is written in python, using the `fuzzy_match` option from
  [regex](https://pypi.org/project/regex/) module to give user feedback
  (via terminal colors) about the possible location of the error(s).
- python testing and code coverage tooling
- GitHub workflows for pre-commit and python tests
- licensed as GPLv3

## [v1.2.0] - 2020-07-31

### Added

- Added docker-based hooks `check-dhcp-config` and `check-dns-config` to run
  the application's own parser validation code in a container.

## [v1.1.0] - 2020-07-31

### Added

- First release with `check-ipv6-case` hook
