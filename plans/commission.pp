# Commission a node and connect it to the Puppet infrastructure
#
# @param nodes The nodes to commission
# @param custom_facts Custom facts to set on comissioned nodes
# @param puppet_settings Puppet settings to configure on comissioned nodes
plan commission::commission(
  TargetSpec $nodes,
  Hash[String[1], Any] $custom_facts = {},
  Hash[String[1], Any] $puppet_settings = {},
) {
  $commission_timestamp = Timestamp()

  upload_file('commission/motd.commissioned', '/etc/motd', $nodes, '_run_as' => 'root')

  # lspci is needed by facter to determine if a node is physical or virutal
  run_task('package', $nodes, 'install lspci', '_run_as' => 'root', 'action' => 'install', 'name' => 'pciutils')

  run_task('puppet_agent::install', $nodes, '_run_as' => 'root')

  run_task('commission::add_custom_facts', $nodes, '_run_as' => 'root', 'facts' => $custom_facts)

  run_task('commission::set_puppet_config', $nodes, '_run_as' => 'root', 'settings' => $puppet_settings)

  run_command('/opt/puppetlabs/bin/puppet agent --test', $nodes, '_run_as' => 'root', '_catch_errors' => true)

  $certificate_requests = Hash(run_task('commission::get_certificate_request', $nodes, '_run_as' => 'root').map |$result| {
      # Extract the cername from the ssh connexion string that can be in the form [user@]certname[:port]
      $certname = $result.target.name.regsubst('^[[:alpha:]]+@', '').regsubst(':[[:digit:]]+$', '')

      Array([$certname, $result.value])
  })

  run_task('commission::sign_certificate_requests', 'puppet', '_run_as' => 'root', certificate_requests => $certificate_requests)

  run_task('service', $nodes, 'Starting puppet', '_run_as' => 'root', 'action' => 'start', 'name' => 'puppet')

  run_task('commission::add_custom_facts', $nodes, '_run_as' => 'root', 'facts' => { 'comissioned_at' => $commission_timestamp })
}
