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

    bootrap_output = `puppet ssl bootstrap --color false --waitforcert 0 2>&1`

    fingerprint_output = `puppet agent --color false --fingerprint 2>&1`
    fingerprint_output =~ /\A\(([^)]+)\)\s+([[:xdigit:]:]+)/
    raise(TaskHelper::Error.new("Failed to get certificate request\n===> `puppet ssl bootstrap --waitforcert 0` output:\n#{bootrap_output}\n===> `puppet agent --fingerprint` output:\n#{fingerprint_output}", 'get_certificate_request')) if Regexp.last_match.nil?

    {
      digest: Regexp.last_match(1),
      fingerprint: Regexp.last_match(2),
    }
  end
end

GetCertificateRequest.run if $PROGRAM_NAME == __FILE__
