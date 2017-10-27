#!/bin/bash

chown -R puppet:puppet /etc/puppetlabs/puppet/ssl
chown -R puppet:puppet /opt/puppetlabs/server/data/puppetserver/

if test -n "${PUPPETDB_SERVER_URLS}" ; then
  sed -i "s@^server_urls.*@server_urls = ${PUPPETDB_SERVER_URLS}@" /etc/puppetlabs/puppet/puppetdb.conf
fi

if test ! -f /etc/puppetlabs/puppet/puppet.conf ; then
  cat << 'EOF' > /etc/puppetlabs/puppet/puppet.conf
# This file can be used to override the default puppet settings.
# See the following links for more details on what settings are available:
# - https://docs.puppetlabs.com/puppet/latest/reference/config_important_settings.html
# - https://docs.puppetlabs.com/puppet/latest/reference/config_about_settings.html
# - https://docs.puppetlabs.com/puppet/latest/reference/config_file_main.html
# - https://docs.puppetlabs.com/puppet/latest/reference/configuration.html
[master]
vardir = /opt/puppetlabs/server/data/puppetserver
logdir = /var/log/puppetlabs/puppetserver
rundir = /var/run/puppetlabs/puppetserver
pidfile = /var/run/puppetlabs/puppetserver/puppetserver.pid
codedir = /etc/puppetlabs/code
autosign = true
EOF
fi

if test ! -f /etc/puppetlabs/puppet/hiera.yaml ; then
  cat << 'EOF' > /etc/puppetlabs/puppet/hiera.yaml
---
:backends:
  - yaml
:hierarchy:
  - "nodes/%{::trusted.certname}"
  - common

:yaml:
# datadir is empty here, so hiera uses its defaults:
# - /etc/puppetlabs/code/environments/%{environment}/hieradata on *nix
# - %CommonAppData%\PuppetLabs\code\environments\%{environment}\hieradata on Windows
# When specifying a datadir, make sure the directory exists.
  :datadir:
EOF
fi

if test ! -f /etc/puppetlabs/puppet/auth.conf ; then
  cat << 'EOF' > /etc/puppetlabs/puppet/auth.conf
### Authenticated ACLs - these rules apply only when the client
### has a valid certificate and is thus authenticated

path /puppet/v3/environments
method find
allow *

# allow nodes to retrieve their own catalog
path ~ ^/puppet/v3/catalog/([^/]+)$
method find
allow $1

# allow nodes to retrieve their own node definition
path ~ ^/puppet/v3/node/([^/]+)$
method find
allow $1

# allow all nodes to store their own reports
path ~ ^/puppet/v3/report/([^/]+)$
method save
allow $1

# Allow all nodes to access all file services; this is necessary for
# pluginsync, file serving from modules, and file serving from custom
# mount points (see fileserver.conf). Note that the `/file` prefix matches
# requests to both the file_metadata and file_content paths. See "Examples"
# above if you need more granular access control for custom mount points.
path /puppet/v3/file
allow *

path /puppet/v3/status
method find
allow *

# allow all nodes to access the certificates services
path /puppet-ca/v1/certificate_revocation_list/ca
method find
allow *

### Unauthenticated ACLs, for clients without valid certificates; authenticated
### clients can also access these paths, though they rarely need to.

# allow access to the CA certificate; unauthenticated nodes need this
# in order to validate the puppet master's certificate
path /puppet-ca/v1/certificate/ca
auth any
method find
allow *

# allow nodes to retrieve the certificate they requested earlier
path /puppet-ca/v1/certificate/
auth any
method find
allow *

# allow nodes to request a new certificate
path /puppet-ca/v1/certificate_request
auth any
method find, save
allow *

# deny everything else; this ACL is not strictly necessary, but
# illustrates the default policy.
path /
auth any
EOF
fi

exec /opt/puppetlabs/bin/puppetserver foreground
