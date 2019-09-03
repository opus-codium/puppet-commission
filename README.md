# puppet-commission

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

```
bolt plan run commission::commission -n host4.example.com,host5.example.com custom_facts=example_fact1=true,example_fact2=false puppet_settings=server=puppet.example.com,splay=true
```

### Optional parameters:

#### `custom_facts`

A coma-separated list of `name=value` facts.  Each fact will be configured as a structured data fact using a YAML file.

#### `puppet_settings`

A coma-separated list of `name=value` settings.

## Decommissioning an old node

```
bolt plan run commission::decommission -n host1.example.com,host3.example.com
```
