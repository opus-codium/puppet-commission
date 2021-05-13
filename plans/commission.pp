# Commission a node and connect it to the Puppet infrastructure
#
# @param nodes The nodes to commission
# @param custom_facts Custom facts to set on comissioned nodes
# @param puppet_settings Puppet settings to configure on comissioned nodes
plan commission::commission(TargetSpec $nodes, Hash[String[1],Any] $custom_facts = {}, Optional[String] $puppet_settings) {
  $commission_timestamp = Timestamp()

  upload_file('commission/motd.commissioned', '/etc/motd', $nodes, '_run_as' => 'root')

  # lspci is needed by facter to determine if a node is physical or virutal
  run_task('package', $nodes, 'install lspci', '_run_as' => 'root', 'action' => 'install', 'name' => 'pciutils')

  run_task('puppet_agent::install', $nodes, '_run_as' => 'root')

  run_task('commission::add_custom_facts', $nodes, '_run_as' => 'root', 'facts' => $custom_facts)

  if $puppet_settings {
    run_script('commission/setup-puppet-agent.sh', $nodes, '_run_as' => 'root', 'arguments' => [$puppet_settings])
  }

  run_command('/opt/puppetlabs/bin/puppet agent --test', $nodes, '_run_as' => 'root', '_catch_errors' => true)

  $fingerprints = run_task('commission::agent_certificate_fingerprint', $nodes, '_run_as' => 'root')
  $fingerprints.each |$result| {
    run_task('commission::sign_agent_certificate', 'puppet', '_run_as' => 'root', 'certname' => $result.target.name.regsubst('^[[:alpha:]]+@', '').regsubst(':[[:digit:]]+$', ''), 'digest' => $result['digest'], 'fingerprint' => $result['fingerprint'])
  }

  run_task('service', $nodes, 'Starting puppet', '_run_as' => 'root', 'action' => 'start', 'name' => 'puppet')

  run_task('commission::add_custom_facts', $nodes, '_run_as' => 'root', 'facts' => { 'comissioned_at' => $commission_timestamp })
}
