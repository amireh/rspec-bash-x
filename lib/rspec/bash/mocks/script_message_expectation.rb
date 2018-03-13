require 'rspec/mocks'
require 'rspec/mocks/argument_list_matcher'
require 'rspec/mocks/matchers/expectation_customization'

module RSpec
  module Bash
    module Mocks
      class ScriptMessageExpectation
        attr_reader :expected_args, :message

        def initialize(double:, display_name:, error_generator:, backtrace_line: nil)
          @double = double
          @display_name = display_name
          @error_generator = error_generator
          @backtrace_line = backtrace_line
          @expected_args = double.expected_calls
          @message = @display_name
        end

        def invoke(*)
        end

        def matches?(*)
        end

        def called_max_times?(*)
          false
        end

        def verify_messages_received(script)
          type, expected_count = *@double.expected_call_count
          actual_count = @double.call_count(script)

          report = lambda {
            @error_generator.raise_expectation_error(
              @display_name,
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

          @double.call_args(script).tap do |actual_args|
            @double.expected_calls.each_with_index do |args, index|
              expected = args
              actual = actual_args[index]

              if actual != expected
                @error_generator.raise_unexpected_message_args_error(
                  self,
                  actual_args.map { |x| Array(x) },
                )
                break
              end
            end
          end
        end

        def unadvise(*)
        end
      end
    end
  end
end