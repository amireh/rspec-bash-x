require 'rspec/mocks'
require 'rspec/mocks/argument_list_matcher'
require 'rspec/mocks/matchers/expectation_customization'

module BashIt
  module RSpec
    class ShellScriptMessageExpectation
      def initialize(spec, error_generator, backtrace_line=nil)
        @spec, @error_generator, @backtrace_line = spec, error_generator, backtrace_line
      end

      def invoke(*_)
        puts "hello???"
        @received = true
        @response
      end

      # def matches?(message, *_)
      #   puts "hello???"
      #   @message == message.to_sym
      # end

      def called_max_times?
        puts "hello???"
        false
      end

      def verify_messages_received(script)
        type, expected_count = *@spec[:call_count]
        actual_count = script.calls_for(@spec[:routine]).count

        report = lambda {
          @error_generator.raise_expectation_error(
            @spec[:routine],
            expected_count,
            ::RSpec::Mocks::ArgumentListMatcher::MATCH_ALL,
            actual_count,
            nil,
            [],
            @backtrace_line
          )
        }


        case type
        when :at_least
          report[] if actual_count < expected_count
        when :at_most
          report[] if actual_count > expected_count
        when :exactly
          report[] if actual_count != expected_count
        else
          fail "Unrecognized call-count quantifier \"#{type}\""
        end
      end

      def unadvise(_)
      end
    end
  end
end
