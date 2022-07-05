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

## Getting started

Use this module to setup commissioning / decommissioning plans tailored to your site.  We ship two sample plans with the module: `commission::commission` and `commission::decommission`.  These plans are site-agnostic and not too much opiniated to be used in any infrastructure.  Use them to give a try to the module and as a template for your site-specific plans.

To setup site-specific plan for your *ACME* organization, start with your Bolt project:

```sh-session
romain@marvin ~ % bolt project init --modules opuslabs-commission acme
Installing project modules

  → Resolving module dependencies, this might take a moment

  → Writing Puppetfile at ~/acme/Puppetfile

  → Syncing modules from ~/acme/Puppetfile to ~/acme/.modules

  → Generating type references

Successfully synced modules from ~/acme/Puppetfile to ~/acme/.modules
romain@marvin % cd acme
romain@marvin ~/acme % mkdir -p modules/acme/plans
romain@marvin ~/acme % sed -e 's/commission::commission/acme::commission/' < .modules/commission/plans/commission.pp > modules/acme/plans/commission.pp
romain@marvin ~/acme % bolt plan show
Plans
  acme::commission       Commission a node and connect it to the Puppet infrastructure
[...]
```

Edit the `modules/acme/plans/commission.pp` plan to fit your site policies, requirements, etc.  Feel free to hardcode the puppet server name, fetch data from PuppetDB, prompt the user for inputs, and so on…  When done, setup a decommissioning plan in a similar fashion.

## Commissioning nodes

```
romain@marvin ~/acme % bolt plan run acme::commission -t node1.example.com,node2.example.com
```

## Decommissioning nodes

```
romain@marvin ~/acme % bolt plan run acme::decommission -t node1.example.com,node2.example.com
```
