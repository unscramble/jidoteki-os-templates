#!/bin/bash
#
# Bootstrap script for setting up CentOS as a vagrant .box
#
# Copyright (c) 2013 Alex Williams, Unscramble <license@unscramble.jp>

UNZIP=`which unzip`
TAR=`which tar`

fail_and_exit() {
        echo "Provisioning failed"
        exit 1
}

# Install some dependencies
yum install python-jinja2 && \
wget http://pyyaml.org/download/pyyaml/PyYAML-3.10.tar.gz && \
tar -zxvf PyYAML-3.10.tar.gz || fail_and_exit
pushd PyYAML-3.10
  python setup.py install || fail_and_exit
popd

pushd /root
  # Extract ansible and install it
  $TAR -zxvf v1.3.0.tar.gz || fail_and_exit
  pushd ansible-1.3.0
    # Install Ansible
    make install && \
    source hacking/env-setup || fail_and_exit
  popd

  # Extract public provisioning scripts
  $UNZIP -o beta-v2.zip || fail_and_exit
  pushd jidoteki-os-templates-beta-v2/provisioning/vagrant
    # Run ansible in local mode
    ansible-playbook vagrant.yml -i hosts || fail_and_exit
  popd

  # Cleanup
  rm -rf PyYAML-3.10.tar.gz v1.3.0.tar.gz ansible-1.3.0 beta-v2.zip jidoteki-os-templates-beta-v2 bootstrap_centos.sh || fail_and_exit
  history -c
popd

echo "Provisioning completed successfully"
exit 0