#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper'

class DeactivateNodes < TaskHelper
  def task(nodes:, **_kwargs)
    # Prepend AIO path if it exist and is not in $PATH
    if File.directory?('/opt/puppetlabs/bin') &&
       !ENV.fetch('PATH').split(':').include?('/opt/puppetlabs/bin')
      ENV['PATH'] = "/opt/puppetlabs/bin:#{ENV.fetch('PATH')}"
    end

    system('puppet', 'node', 'deactivate', *nodes) || raise(TaskHelper::Error.new('Failed to deactivate nodes', 'deactivate_nodes'))

    nil
  end
end

DeactivateNodes.run if $PROGRAM_NAME == __FILE__
