#!/bin/sh

# Run on VM to bootstrap Puppet Master server

if ps aux | grep "puppet master" | grep -v grep 2> /dev/null
then
    echo "Puppet Master is already installed. Exiting..."
else
    # Install Puppet Master
    echo "Start install puppet master"
    sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm && \
    sed '22c enable=1' /etc/yum.repos.d/puppetlabs.repo && \
    sudo yum -y install puppetserver && \
    sudo puppet resource package puppet-server ensure=latest && \
    sudo yum -y install puppet
    sudo puppet resource package puppet ensure=latest

    # Configure /etc/hosts file
    echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "# Host config for Puppet Master and Agent Nodes" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.5    puppet.example.com  puppet" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.10   wso2.example.com  wso2" | sudo tee --append /etc/hosts 2> /dev/null &&

    # Add optional alternate DNS names to /etc/puppet/puppet.conf
    sudo sed -i 's/.*\[main\].*/&\ndns_alt_names = puppet,puppet.example.com/' /etc/puppet/puppet.conf

    # Install some initial puppet modules on Puppet Master server
    sudo puppet module install puppetlabs-ntp && \
    sudo puppet module install garethr-docker && \
    sudo puppet module install puppetlabs-git && \
    sudo puppet module install puppetlabs-vcsrepo && \
    sudo puppet module install garystafford-fig &&

    # symlink manifest from Vagrant synced folder location
    ln -s /vagrant/site.pp /etc/puppet/manifests/site.pp
fi
sudo systemctl enable puppetmaster