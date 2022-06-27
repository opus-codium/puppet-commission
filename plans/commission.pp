# Commission a node and connect it to the Puppet infrastructure
#
# @param nodes The nodes to commission
# @param puppetserver The Puppet Server that manage the nodes
# @param customer The customer the nodes belongs to
# @param provider The provider of the nodes
# @param city The city where the nodes are located in
# @param country The country the nodes are located in
plan commission::commission(
  TargetSpec          $nodes,
  String[1]           $puppetserver = 'puppet',
  Optional[String[1]] $customer = undef,
  Optional[String[1]] $provider = undef,
  Optional[String[1]] $city     = undef,
  Optional[String[1]] $country  = undef,
) {
  $commission_timestamp = Timestamp()

  $custom_facts = {
    customer => $customer.lest || { prompt('Customer') },
    provider => $provider.lest || { prompt('Provider') },
    city     => $city.lest || { prompt('City') },
    country  => $country.lest || { prompt('County') },
  }

  $puppet_settings = {
    server => $puppetserver,
    splay  => true,
  }

  upload_file('commission/motd.commissioned', '/etc/motd', $nodes, '_run_as' => 'root')
  # lspci is needed by facter to determine if a node is physical or virutal
  run_task('package', $nodes, 'install lspci', '_run_as' => 'root', 'action' => 'install', 'name' => 'pciutils')
  run_task('puppet_agent::install', $nodes, '_run_as' => 'root')

  run_task('commission::add_custom_facts', $nodes, '_run_as' => 'root', 'facts' => $custom_facts)
  run_task('commission::set_puppet_config', $nodes, '_run_as' => 'root', 'settings' => $puppet_settings)

  $certificate_requests = Hash(run_task('commission::get_certificate_request', $nodes, '_run_as' => 'root').map |$result| {
      # Extract the cername from the ssh connexion string that can be in the form [user@]certname[:port]
      $certname = $result.target.name.regsubst('^[[:alpha:]]+@', '').regsubst(':[[:digit:]]+$', '')

      Array([$certname, $result.value])
  })
  run_task('commission::sign_certificate_requests', $puppetserver, '_run_as' => 'root', certificate_requests => $certificate_requests)

  run_task('service', $nodes, 'Starting puppet', '_run_as' => 'root', 'action' => 'start', 'name' => 'puppet')
  run_task('commission::add_custom_facts', $nodes, '_run_as' => 'root', 'facts' => { 'comissioned_at' => Timestamp() })
}
