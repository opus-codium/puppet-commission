#!/bin/sh
/opt/puppetlabs/bin/puppet resource cron | sed "s/ensure *=> 'present'/ensure => 'absent'/" | /opt/puppetlabs/bin/puppet apply -t

if [ $? -eq 0 -o $? -eq 2 ]; then
	exit 0
else
	exit 1
fi
