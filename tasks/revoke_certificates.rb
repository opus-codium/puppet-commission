#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper'

class RevokeCertificates < TaskHelper
  def task(certificates:, **_kwargs)
    # Prepend AIO path if it exist and is not in $PATH
    if File.directory?('/opt/puppetlabs/bin') &&
       !ENV.fetch('PATH').split(':').include?('/opt/puppetlabs/bin')
      ENV['PATH'] = "/opt/puppetlabs/bin:#{ENV.fetch('PATH')}"
    end

    system('puppetserver', 'ca', 'revoke', '--certname', certificates.join(',')) || raise(TaskHelper::Error.new('Failed to revoke certificates', 'revoke_certificates', 'puppetserver exited with a non-null error code'))

    nil
  end
end

RevokeCertificates.run if $PROGRAM_NAME == __FILE__
