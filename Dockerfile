FROM debian:buster-slim

ENV PATH=$PATH:/vagrant/exec

WORKDIR /src
ADD . .

RUN set -e \
 && apt-get update -q \
 && apt-get install -yq wget git procps kmod rsync ruby-dev curl \
 && wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux32 -O /usr/bin/jq \
 && chmod +x /usr/bin/jq \
 && wget https://releases.hashicorp.com/vagrant/2.2.4/vagrant_2.2.4_x86_64.deb \
 && dpkg -i vagrant_2.2.4_x86_64.deb \
 && rm vagrant_2.2.4_x86_64.deb \
 && vagrant --version \
 && vagrant plugin install vagrant-env \
 && gem build vagrant-vmck.gemspec \
 && vagrant plugin install vagrant-vmck-*.gem \
 && gem_dir="$(ls -d /root/.vagrant.d/gems/*/gems/vagrant-vmck-*)" \
 && rm -rf "$gem_dir" \
 && ln -s /src "$gem_dir" \
 && apt-get purge -y wget ruby-dev \
 && apt-get clean && rm -rf /var/lib/apt/lists/*
