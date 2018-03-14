require 'rspec/mocks'

module RSpec
  module Bash
    module Mocks
      module Matchers
        # @private
        class BaseMatcher
          include ::RSpec::Mocks::Matchers::Matcher

          attr_reader :double

          def initialize()
            fail "@double must be created by implementation" if @double.nil?
            fail "@display_name must be specified by implementation" if @display_name.nil?
          end

          def name
            @display_name
          end

          def with_args(args)
            tap {
              @double.expected_calls << args
              @double.behaviors << create_behavior({ args: args })
            }
          end

          def and_yield(subshell: true, times: 1, &body)
            tap {
              @double.subshell = subshell

              behavior = find_last_blank_or_create_behavior
              behavior[:body] = body
              behavior[:charges] = behavior[:charges] == 0 ? times : behavior[:charges]
              behavior[:subshell] = subshell
            }
          end

          def and_return(code, times: 1)
            and_yield(subshell: false, times: times) { |*| "return #{code}" }
          end

          def and_always_return(code)
            and_return(code, times: Float::INFINITY)
          end

          def and_always_yield(subshell: true, &body)
            and_yield(subshell: subshell, times: Float::INFINITY, &body)
          end

          def exactly(n)
            tap do
              if @double.behaviors.last
                @double.behaviors.last[:charges] = n

                (n-1).times do
                  @double.expected_calls << @double.expected_calls.last
                end
              else
                @double.expected_call_count = [:exactly, n]
              end
            end
          end

          def at_least(n)
            tap { @double.expected_call_count = [:at_least, n] }
          end

          def at_most(n)
            tap { @double.expected_call_count = [:at_most, n] }
          end

          def and_call_original
            tap { @double.call_original = true }
          end

          def never
            exactly(0)
          end

          def once
            exactly(1)
          end

          def twice
            exactly(2)
          end

          def thrice
            exactly(3)
          end

          def times
            self
          end

          # @private
          #
          # (RSpec::Bash::Script): RSpec::Bash::Mocks::ScriptMessageExpectation
          def matches?(subject, &block)
            proxy_for(subject).expect_message(
              double: @double,
              display_name: @display_name
            )
          end

          # @private
          #
          # (RSpec::Bash::Script): RSpec::Bash::Mocks::ScriptMessageExpectation
          def setup_allowance(subject, &block)
            proxy_for(subject).allow_message(
              double: @double
            )
          end

          protected

          def proxy_for(subject)
            ::RSpec::Mocks.space.proxy_for(subject)
          end

          def find_last_blank_or_create_behavior
            @double.behaviors.detect { |x| x[:body].nil? } || begin
              create_behavior.tap { |x| @double.behaviors << x }
            end
          end

          def create_behavior(args: nil, body: nil, charges: 0)
            {
              args: args,
              body: body,
              charges: charges
            }
          end
        end
      end
    end
  end
end