# puppet-commission

<!-- header GFM -->
[![Build Status](https://img.shields.io/github/workflow/status/opus-codium/puppet-commission/Release)](https://github.com/opus-codium/puppet-commission/releases)
[![Puppet Forge](https://img.shields.io/puppetforge/v/opuscodium/commission.svg)](https://forge.puppetlabs.com/opuscodium/commission)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/opuscodium/commission.svg)](https://forge.puppetlabs.com/opuscodium/commission)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/opuscodium/commission.svg)](https://forge.puppetlabs.com/opuscodium/commission)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/opuscodium/commission.svg)](https://forge.puppetlabs.com/opuscodium/commission)
[![License](https://img.shields.io/github/license/opus-codium/puppet-commission.svg)](https://github.com/voxpupuli/opuscodium-commission/blob/master/LICENSE.md)
<!-- header -->

Commission / decommission Puppet nodes easily.

This module provides [Bolt](https://puppet.com/docs/bolt/latest/bolt.html) plans to commission / decommission [Puppet](https://puppet.com/docs/puppet/latest/puppet_index.html) nodes.

## Prerequisites

The name `puppet` must be something that resolves to your site's Puppet Master.  In other word, the exact command `bolt command run 'hostname -f' -n puppet` should succeed.

```sh-session
romain@marvin ~ % bolt command run 'hostname -f' -n puppet
Started on host2.example.com...
Finished on host2.example.com:
  STDOUT:
    host2.example.com
Successful on 1 node: host2.example.com
Ran on 1 node in 2.21 seconds
romain@marvin ~ %
```

This can be easily achieved by [providing an alias to a target in your inventory file](https://puppet.com/docs/bolt/latest/inventory_file_v2.html#provide-an-alias-to-a-target), e.g.:

```yaml
version: 2
targets:
  - host1.example.com
  - uri: host2.example.com
    alias: puppet
  - host3.example.com
```

## Commissioning a new node

Adjust your inventory file so that you can connect as root without specifying arguments.  The exact command `bolt command run id -n host4.example.com` should succeed show you are _root_.

```sh-session
romain@marvin ~ % bolt command run id -n host4.example.com
Started on host4.example.com...
Finished on host4.example.com:
  STDOUT:
    uid=0(root) gid=0(root) groups=0(root)
Successful on 1 node: host4.example.com
Ran on 1 node in 2.12 sec
```
This can be achieved using something similar to the following in your inventory file:

```yaml
version: 2
targets:
  - name: "host4.example.com"
    uri: "host4.example.com"
    config:
      ssh:
        user: "root"
        password: "secret"
  - name: "host5.example.com"
    uri: "host5.example.com"
    config:
      ssh:
        user: "root"
        password: "secret"
```

You can then commission the nodes:

```
bolt plan run commission::commission -n host4.example.com,host5.example.com custom_facts=example_fact1=true,example_fact2=false puppet_settings=server=puppet.example.com,splay=true
```

### Optional parameters:

#### `custom_facts`

A coma-separated list of `name=value` facts.  Each fact will be configured as a structured data fact using a YAML file.

Example: `custom_facts=customer=foo,provider=bar`

#### `puppet_settings`

A coma-separated list of `name=value` settings.

Example: `puppet_settings=server=puppet.example.com,splay=true`

## Decommissioning an old node

```
bolt plan run commission::decommission -n host1.example.com,host3.example.com
```
