require_relative './bash/configuration'
require_relative './bash/fd'
require_relative './bash/noisy_thread'
require_relative './bash/open3'
require_relative './bash/script'
require_relative './bash/script_evaluator'
require_relative './bash/script_generator'
require_relative './bash/support'
require_relative './bash/version'
require_relative './bash/mocks/doubles'
require_relative './bash/mocks/matchers'
require_relative './bash/mocks/script_message_expectation'
require_relative './bash/mocks/script_proxy'
require_relative '../../ext/rspec-mocks/space'

module RSpec
  module Bash
    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configure(&block)
      yield configuration
    end
  end
end