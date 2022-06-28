#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'yaml'

require_relative '../../ruby_task_helper/files/task_helper'

class GetCertificateRequest < TaskHelper
  def task(**_kwargs)
    # Prepend AIO path if it exist and is not in $PATH
    if File.directory?('/opt/puppetlabs/puppet/bin') &&
       !ENV['PATH'].split(':').include?('/opt/puppetlabs/puppet/bin')
      ENV['PATH'] = "/opt/puppetlabs/puppet/bin:#{ENV['PATH']}"
    end

    `puppet agent --fingerprint` =~ /\A\(([^)]+)\)\s+([[:xdigit:]:]+)/

    {
      digest: Regexp.last_match(1),
      fingerprint: Regexp.last_match(2),
    }
  end
end

GetCertificateRequest.run if $PROGRAM_NAME == __FILE__
