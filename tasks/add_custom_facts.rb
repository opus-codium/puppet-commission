#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'open3'
require 'yaml'

require_relative '../../ruby_task_helper/files/task_helper'

class CustomFactsAdder < TaskHelper
  def task(facts: nil, custom_facts_dir: nil, **_kwargs)
    if custom_facts_dir.nil?
      # Prepend AIO path if it exist and is not in $PATH
      if File.directory?('/opt/puppetlabs/puppet/bin') &&
         !ENV['PATH'].split(':').include?('/opt/puppetlabs/puppet/bin')
        ENV['PATH'] = "/opt/puppetlabs/puppet/bin:#{ENV['PATH']}"
      end

      stdout, _stderr, _status = Open3.capture3('facter', 'os.family')
      osfamily = stdout.strip
      custom_facts_dir = case osfamily
                         when 'FreeBSD'
                           '/usr/local/etc/facter/facts.d'
                         when 'windows'
                           'C:\ProgramData\PuppetLabs\facter\facts.d'
                         else
                           '/etc/puppetlabs/facter/facts.d'
                         end
    end

    FileUtils.mkdir_p(custom_facts_dir)

    facts.each do |key, value|
      fact_yaml_path = File.join(custom_facts_dir, "#{key}.yaml")
      fact_yaml = { key.to_s => value }.to_yaml

      IO.write(fact_yaml_path, fact_yaml)
    end

    nil
  end
end

CustomFactsAdder.run if $PROGRAM_NAME == __FILE__
