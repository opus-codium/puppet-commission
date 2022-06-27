# Decommission a node and disconnect it from the Puppet infrastructure
#
# @param nodes The nodes to decommission
plan commission::decommission(TargetSpec $nodes, String[1] $puppetserver = undef) {
  $puppetserver_node = $puppetserver.lest || { prompt('puppetserver') }

  upload_file('commission/motd.decommissioned', '/etc/motd', $nodes, '_run_as' => 'root')

  run_task('service', $nodes, 'Stopping puppet', '_run_as' => 'root', 'action' => 'stop', 'name' => 'puppet')

  run_task('service', $nodes, 'Stopping syslog-ng', '_run_as' => 'root', 'action' => 'stop', 'name' => 'syslog-ng')
  run_task('package', $nodes, 'Uninstalling syslog-ng', '_run_as' => 'root', 'action' => 'uninstall', 'name' => 'syslog-ng-core')

  run_task('service', $nodes, 'Stopping collectd', '_run_as' => 'root', 'action' => 'stop', 'name' => 'collectd')
  run_task('package', $nodes, 'Uninstalling collectd', '_run_as' => 'root', 'action' => 'uninstall', 'name' => 'collectd')

  run_script('commission/clean-cron-jobs.sh', $nodes, '_run_as' => 'root')

  get_targets($nodes).each |$node| {
    run_command("/opt/puppetlabs/bin/puppetserver ca revoke --certname ${node.name}", $puppetserver_node, '_run_as' => 'root')
    run_command("/opt/puppetlabs/bin/puppet node deactivate ${node.name}", $puppetserver_node, '_run_as' => 'root')
  }

  run_task('package', $nodes, 'Uninstalling puppet-agent', '_run_as' => 'root', 'action' => 'uninstall', 'name' => 'puppet-agent')
}
