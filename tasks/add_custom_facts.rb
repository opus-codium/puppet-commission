#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'yaml'

require_relative '../../ruby_task_helper/files/task_helper'

class CustomFactsAdder < TaskHelper
  def task(facts: nil, custom_facts_dir: nil, **_kwargs)
    if custom_facts_dir.nil?
      stdout, _stderr, _status = Open3.capture3('facter', '-p', 'osfamily')
      osfamily = stdout.strip
      custom_facts_dir = case osfamily
                         when 'FreeBSD'
                           '/usr/local/etc/facter/facts.d'
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
  end
end

CustomFactsAdder.run if $PROGRAM_NAME == __FILE__
