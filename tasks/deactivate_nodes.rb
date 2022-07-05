#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper'

class DeactivateNodes < TaskHelper
  def task(nodes:, **_kwargs)
    # Prepend AIO path if it exist and is not in $PATH
    if File.directory?('/opt/puppetlabs/puppet/bin') &&
       !ENV['PATH'].split(':').include?('/opt/puppetlabs/puppet/bin')
      ENV['PATH'] = "/opt/puppetlabs/puppet/bin:#{ENV['PATH']}"
    end

    system('puppet', 'node', 'deactivate', *nodes) || raise(TaskHelper::Error.new('Failed to deactivate nodes', 'deactivate_nodes', 'puppet exited with a non-null error code'))

    nil
  end
end

DeactivateNodes.run if $PROGRAM_NAME == __FILE__
