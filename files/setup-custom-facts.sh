#!/bin/sh
mkdir -p /etc/puppetlabs/facter/facts.d

IFS=,
set -- $*
for fact; do
	k=${fact%=*}
	v=${fact#*=}
	cat << YAML > "/etc/puppetlabs/facter/facts.d/${k}.yaml"
---
$k: "$v"
YAML
done
