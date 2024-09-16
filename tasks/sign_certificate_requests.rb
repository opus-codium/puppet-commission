#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper'

class SignCertificateRequests < TaskHelper
  def task(certificate_requests:, **_kwargs)
    # Prepend AIO path if it exist and is not in $PATH
    if File.directory?('/opt/puppetlabs/bin') &&
       !ENV.fetch('PATH').split(':').include?('/opt/puppetlabs/bin')
      ENV['PATH'] = "/opt/puppetlabs/bin:#{ENV.fetch('PATH')}"
    end

    certificate_requests.each do |node, details|
      if pending_requests[node] != details
        raise TaskHelper::Error.new("No certificate request was found for #{node} with digest #{details[:digest]} and fingerprint #{details[:fingerprint]}",
                                    'sign_agent_certificate/certificate_request_not_found')
      end

      system('puppetserver', 'ca', 'sign', '--certname', node.to_s) || raise(TaskHelper::Error.new('Failed to sign certificate requests', 'sign_certificate_requests'))
    end

    nil
  end

  def pending_requests
    @pending_requests ||= begin
      res = {}
      `puppetserver ca list`.lines.map do |line|
        next unless line =~ %r{\A\s*(\S+)\s+\(([^)]+)\)\s+([[:xdigit:]:]+)}

        res[Regexp.last_match(1).to_sym] = {
          digest: Regexp.last_match(2),
          fingerprint: Regexp.last_match(3),
        }
      end
      res
    end
  end
end

SignCertificateRequests.run if $PROGRAM_NAME == __FILE__
