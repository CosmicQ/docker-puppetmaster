docker-puppetserver
===========

A simple puppetserver to get started

[![](https://images.microbadger.com/badges/image/cosmicq/docker-puppetserver.svg)](http://microbadger.com/images/cosmicq/docker-puppetserver "Get your own image badge on microbadger.com")

[![](https://images.microbadger.com/badges/version/cosmicq/docker-puppetserver.svg)](http://microbadger.com/images/cosmicq/docker-puppetserver "Get your own version badge on microbadger.com")

This is mostly taken from [puppet/puppetserver-standalone](https://hub.docker.com/r/puppet/puppetserver-standalone/).  
I changed the base image from Ubuntu to Phusion and enabled ssh access.  
I wanted to be able to connect to the puppetmaster and run 
'''puppet module install''' commands.

### TL;DR ###

Make the persistent directories

    mkdir -p /srv/puppet/code
    mkdir /srv/puppet/ssl
    mkdir /srv/puppet/server

Here is a sample command using all the options.

    docker run -d --restart=always -p 8140:8140 \
    -v /srv/puppet/code:/etc/puppetlabs/code \
    -v /srv/puppet/ssl:/etc/puppetlabs/puppet/ssl \
    -v /srv/puppet/server:/opt/puppetlabs/server/data/puppetserver \
    -v /home/cosmicq/.ssh:/root/.ssh \
    --name puppet \
    --hostname puppetmaster.cosmicegg.net \
    cosmicq/docker-puppetserver

Ssh in and manage your server

    ssh root@172.16.0.2

# SSH

Make sure you have run ssh-keygen and have an authorized_keys files in your home directory
    ssh-keygen
    (accept the defaults)
    
    cd ~/.ssh
    cat id_dsa.pub > authorized_keys

# Puppet subdirectories

## /srv/puppet/code

Puppet is expecting to find the modules in:
    /srv/puppet/code/environments/production/manifests
                                            /modules

## /srv/puppet/ssl

This is where the client/server SSL certs are.  You probably want to back this up.

## /srv/puppet/server

Peristant server data.  This is mounted so your puppet server can be rebooted and pick up where it left off.
