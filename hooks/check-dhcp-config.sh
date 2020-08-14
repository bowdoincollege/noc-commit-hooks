#!/bin/bash

set -e
DHCPD=/usr/sbin/dhcpd

# pre-commit will set workdir to /src and mount repo there
cd /src

if type "$DHCPD" >/dev/null 2>&1; then
  for hostdir in * ; do
    if [ -d "${hostdir}" ] && [ "$(basename "${hostdir}")" != "include" ]; then
      echo -n "checking syntax against ISC DHCP parser for $(basename "${hostdir}")..."
      rm -rf /etc/dhcp/*
      mkdir -p "/etc/dhcp"
      cp -dLr "include/." /etc/dhcp/
      cp -dLr "${hostdir}/." /etc/dhcp/
      if OUTPUT=$($DHCPD -t 2>&1); then
        echo "passed"
      else
        echo "FAILED, exiting."
        echo
        # only output the actual errors
        echo -e "$OUTPUT" | sed -n '/^PID file/,/^Configuration file errors encountered/{//!p}'
        echo
        # bail out immediately if one server failes
        # since almost all configs are common, others servers will likely fail too
        exit 1
      fi
    fi
  done
else
  echo "$DHCPD not installed, skipping checks"
fi
exit 0
