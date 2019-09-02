#!/bin/sh

set -e

/opt/puppetlabs/bin/puppetserver ca list | grep "^ *${PT_certname} *${PT_digest} *${PT_fingerprint}\$"
/opt/puppetlabs/bin/puppetserver ca sign --certname "$PT_certname"
