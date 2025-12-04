# frozen_string_literal: true

require "webmock/rspec"

if ENV["COVER"]
  require "simplecov"
  require "simplecov-lcov"

  SimpleCov::Formatter::LcovFormatter.config do |c|
    c.report_with_single_file = true
    c.single_report_path = "coverage/lcov.info"
  end

  SimpleCov.start do
    enable_coverage :branch
    minimum_coverage line: 100, branch: 100
    add_filter "spec"
    formatter SimpleCov::Formatter::MultiFormatter.new(
      [
        SimpleCov::Formatter::HTMLFormatter,
        SimpleCov::Formatter::LcovFormatter,
      ],
    )
  end
end

require_relative "../config/application"

# Load all shared contexts from support/contexts
Dir[File.join(__dir__, "support", "contexts", "*.rb")].each { |f| require f }

RSpec.configure do |config|
  WebMock.disable_net_connect!

  # Enable color output
  config.color = true

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = "./tmp/rspec_examples.txt"

  # Disable RSpec exposing methods globally on `Module` and `main`
  # This requires using RSpec.describe instead of just describe
  config.disable_monkey_patching!

  # Enable exposing the DSL globally if needed (this allows using describe directly)
  # Set to false if you want to use RSpec.describe explicitly
  config.expose_dsl_globally = true

  # Run specs in random order to surface order dependencies
  config.order = :random

  # Enable filtering examples with :focus
  config.filter_run_when_matching :focus

  # Use different formatters for CI vs local development
  config.formatter = %w[true 1].include?(ENV.fetch("CI", false)) ? :progress : :documentation

  # Apply shared context metadata to host groups (RSpec 4.0 default)
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Enable Ruby warnings
  config.warnings = true

  # Configure expectations
  config.expect_with :rspec do |expectations|
    # Only allow expect syntax, not should syntax
    expectations.syntax = :expect
    # Include chained method descriptions in custom matchers
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # Configure mocks
  config.mock_with :rspec do |mocks|
    # Verify that constants double exist and haven't changed
    mocks.verify_doubled_constant_names = true
    # Verify partial doubles
    mocks.verify_partial_doubles = true
  end
end
