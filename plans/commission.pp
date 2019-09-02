plan commission::commission(TargetSpec $nodes, Optional[String] $custom_facts, Optional[String] $puppet_settings) {
  upload_file('commission/motd.commissioned', '/etc/motd', $nodes, '_run_as' => 'root')

  run_task('puppet_agent::install', $nodes, '_run_as' => 'root')

  if $custom_facts {
    run_script('commission/setup-custom-facts.sh', $nodes, '_run_as' => 'root', 'arguments' => $custom_facts)
  }

  if $puppet_settings {
    run_script('commission/setup-puppet-agent.sh', $nodes, '_run_as' => 'root', 'arguments' => $puppet_settings)
  }

  run_command('/opt/puppetlabs/bin/puppet agent --test', $nodes, '_run_as' => 'root')

  $fingerprints = run_task('commission::agent_certificate_fingerprint', $nodes, '_run_as' => 'root')
  $fingerprints.each |$result| {
    run_task('commission::sign_agent_certificate', 'puppet', '_run_as' => 'root', 'certname' => $result.target.name, 'digest' => $result['digest'], 'fingerprint' => $result['fingerprint'])
  }

  run_task('service', $nodes, 'Starting puppet', '_run_as' => 'root', 'action' => 'start', 'name' => 'puppet')
}
