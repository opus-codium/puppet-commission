#!/bin/sh

set -- `/opt/puppetlabs/bin/puppet agent --fingerprint`

if [ $# -eq 2 ]; then
  cat << EOF
{
  "digest": "$1",
  "fingerprint": "$2"
}
EOF
  exit 0
else
  cat << EOF
{
  "_error": {
    "msg": "'puppet agent --fingerprint' failed",
    "kind": "puppetlabs.tasks/task-error",
    "details": { "exitcode": 1 }
  }
}
EOF
  exit 1
fi
