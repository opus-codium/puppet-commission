plan commission::commission(TargetSpec $nodes) {
  upload_file('commission/motd.commissioned', '/etc/motd', $nodes, '_run_as' => 'root')

}
