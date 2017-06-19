# docker-puppetmaster
A simple puppetmaster to get started

This is mostly taken from [puppet/puppetserver-standalone](https://hub.docker.com/r/puppet/puppetserver-standalone/).  
I changed the base image from Ubuntu to Phusion and enabled ssh.  
I wanted to be able to connect to the puppetmaster and run 
'''puppet module install''' commands.


# How to run

I like to create my persistant files/directories in /srv.

```
docker run -d --restart=always -p 8140:8140 \
-v /srv/puppet/code:/etc/puppetlabs/code \
-v /srv/puppet/ssl:/etc/puppetlabs/puppet/ssl \
-v /srv/puppet/server:/opt/puppetlabs/server/data/puppetserver \
-v /home/cosmicq/.ssh:/root/.ssh \
--name puppet \
--hostname puppetmaster.cosmicegg.net \
cosmicq/docker-puppetserver
```

# Connecting to the instance

```
docker inspect puppet
```

Find the IP address the container is running as.  Usually something like 172.16.0.2.
```
ssh root@172.16.0.2
```

This will allow you in the container and let you perform actions.
