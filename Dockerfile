FROM debian:jessie
RUN apt-get update

# install anyy dependencies
RUN DEBIAN_FRONTEND=noninteractive \
  apt-get install -y -q bind9 isc-dhcp-server
RUN rm -rf /var/lib/apt/lists/*

# we cannot use chroot, since pre-commit runs docker as non-root user
# prepare bind configuration directory to be writable
RUN rm -rf /etc/bind
RUN mkdir /etc/bind && chmod 777 /etc/bind

# add all hook entry points
ADD hooks/check-dns-config.sh /usr/bin/check-dns-config
RUN chmod a+x /usr/bin/check-dns-config
