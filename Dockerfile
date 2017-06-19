# Taken from puppetlabs/puppet-in-docker (puppetserver-standalone)
#
# I needed to be able to ssh into the container to perform functions like
# puppet module install
#
# This was converted from ubuntu to phusion/baseimage
#

FROM phusion/baseimage:0.9.22
MAINTAINER CosmicQ <cosmicq@cosmicegg.net>

ENV HOME /root
ENV LANG en_US.UTF-8

ENV PUPPET_SERVER_VERSION="2.7.2" 
ENV DUMB_INIT_VERSION="1.2.0" 
ENV UBUNTU_CODENAME="xenial" 
ENV PUPPETSERVER_JAVA_ARGS="-Xms256m -Xmx256m" 
ENV PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH

LABEL org.label-schema.vendor="Puppet" \
      org.label-schema.url="https://github.com/puppetlabs/puppet-in-docker" \
      org.label-schema.name="Puppet Server (No PuppetDB)" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version=$PUPPET_SERVER_VERSION \
      org.label-schema.vcs-url="https://github.com/puppetlabs/puppet-in-docker" \
      org.label-schema.vcs-ref="a2b1fbbc73177ddc3def23d167f9beb9c3ef9f6c" \
      org.label-schema.build-date="2017-02-21T17:25:14Z" \
      org.label-schema.schema-version="1.0" \
      com.puppet.dockerfile="/Dockerfile"

RUN locale-gen en_US.UTF-8
RUN ln -s -f /bin/true /usr/bin/chfn

RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y wget=1.17.1-1ubuntu1 && \
    wget https://apt.puppetlabs.com/puppetlabs-release-pc1-"$UBUNTU_CODENAME".deb && \
    wget https://github.com/Yelp/dumb-init/releases/download/v"$DUMB_INIT_VERSION"/dumb-init_"$DUMB_INIT_VERSION"_amd64.deb && \
    dpkg -i puppetlabs-release-pc1-"$UBUNTU_CODENAME".deb && \
    dpkg -i dumb-init_"$DUMB_INIT_VERSION"_amd64.deb && \
    rm puppetlabs-release-pc1-"$UBUNTU_CODENAME".deb dumb-init_"$DUMB_INIT_VERSION"_amd64.deb && \
    apt-get update && \
    apt-get install --no-install-recommends -y puppetserver="$PUPPET_SERVER_VERSION"-1puppetlabs1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    gem install --no-rdoc --no-ri r10k

RUN puppet config set autosign true --section master

RUN rm -f /etc/service/sshd/down

COPY puppetserver /etc/default/puppetserver
COPY logback.xml /etc/puppetlabs/puppetserver/
COPY request-logging.xml /etc/puppetlabs/puppetserver/
COPY Dockerfile /

ADD start_puppetserver.sh /etc/service/puppetserver/run

EXPOSE 8140

VOLUME [ \
	"/etc/puppetlabs/code/", \
	"/etc/puppetlabs/puppet/ssl/", \
	"/opt/puppetlabs/server/data/puppetserver/", \
	"/root/.ssh" \
]

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
