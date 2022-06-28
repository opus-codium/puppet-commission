#!/usr/bin/env ruby
# frozen_string_literal: true

require 'open3'

require_relative '../../ruby_task_helper/files/task_helper'

class SetPuppetConfig < TaskHelper
  def task(settings:, **_kwargs)
    # Prepend AIO path if it exist and is not in $PATH
    if File.directory?('/opt/puppetlabs/puppet/bin') &&
       !ENV['PATH'].split(':').include?('/opt/puppetlabs/puppet/bin')
      ENV['PATH'] = "/opt/puppetlabs/puppet/bin:#{ENV['PATH']}"
    end

    settings.each do |setting_name, setting_value|
      Open3.capture3('puppet', 'config', 'set', setting_name.to_s, setting_value.to_s)
    end

    nil
  end
end

SetPuppetConfig.run if $PROGRAM_NAME == __FILE__
