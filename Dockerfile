FROM debian:jessie
RUN apt-get update

# install anyy dependencies
RUN DEBIAN_FRONTEND=noninteractive \
  apt-get install -y -q bind9 isc-dhcp-server
RUN rm -rf /var/lib/apt/lists/*

# we cannot use chroot, since pre-commit runs docker as non-root user
# prepare bind configuration directory to be writable
RUN rm -rf /etc/bind /etc/dhcp && \
    mkdir /etc/bind /etc/dhcp && \
    chmod 777 /etc/bind /etc/dhcp

# debian uses /etc/dhcp3, we use /etc/dhcp: symlink them
RUN ln -s dhcp /etc/dhcp3

# add all hook entry points
ADD hooks/check-dns-config.sh /usr/bin/check-dns-config
ADD hooks/check-dhcp-config.sh /usr/bin/check-dhcp-config
RUN chmod a+x /usr/bin/check-dns-config && \
    chmod a+x /usr/bin/check-dhcp-config
