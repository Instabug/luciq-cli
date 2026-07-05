# frozen_string_literal: true

require 'webmock/rspec'
require 'tmpdir'
require 'luciq/cli'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.disable_monkey_patching!
  config.warnings = true
  config.order = :random

  # Keep tests isolated from the developer's real auth state (~/.luciqrc + env),
  # so specs are deterministic regardless of a local `luciq login`.
  config.before do
    isolated_config = File.join(Dir.tmpdir, 'luciqrc-spec')
    File.delete(isolated_config) if File.exist?(isolated_config)
    stub_const('Luciq::Config::CONFIG_FILE', isolated_config)
  end

  config.after do
    ENV.delete('LUCIQ_AUTH_TOKEN')
  end

  WebMock.disable_net_connect!
end
