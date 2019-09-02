#!/bin/sh
IFS=,
set -- $*
for setting; do
	k=${setting%=*}
	v=${setting#*=}
	/opt/puppetlabs/bin/puppet config set "$k" "$v"
done
