# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Luciq::Commands::Query do
  let(:client) { instance_double(Luciq::API::Client) }

  before do
    ENV['LUCIQ_AUTH_TOKEN'] = 'token-123'
    allow(Luciq::API::Client).to receive(:new).and_return(client)
  end

  describe '#crashes_list' do
    it 'maps status names to ids and forwards pagination + typed filters' do
      options = { slug: 'my-app', mode: 'production', limit: 10,
                  status: %w[open in_progress], platform: ['IOS'] }

      expect(client).to receive(:invoke_tool).with(
        'list_crashes',
        hash_including(
          slug: 'my-app', mode: 'production', limit: 10,
          filters: hash_including('status_id' => [1, 3], 'platform' => ['IOS'])
        )
      ).and_return({ 'crashes' => [] })

      expect { described_class.new(options).crashes_list }.to output(/crashes/).to_stdout
    end

    it 'merges the raw --filters JSON escape hatch' do
      options = { slug: 'a', mode: 'production', filters: '{"app_versions":["1.2.3"]}' }

      expect(client).to receive(:invoke_tool).with(
        'list_crashes', hash_including(filters: hash_including('app_versions' => ['1.2.3']))
      ).and_return({})

      expect { described_class.new(options).crashes_list }.to output.to_stdout
    end

    it 'exits with an error on invalid --filters JSON' do
      options = { slug: 'a', mode: 'production', filters: 'not-json' }

      expect { described_class.new(options).crashes_list }
        .to output(/Invalid --filters JSON/).to_stdout.and raise_error(SystemExit)
    end
  end

  describe '#crash_show' do
    it 'forwards the crash number to crash_details' do
      expect(client).to receive(:invoke_tool)
        .with('crash_details', hash_including(slug: 'a', mode: 'production', number: 42))
        .and_return({})

      expect { described_class.new({ slug: 'a', mode: 'production' }).crash_show(42) }.to output.to_stdout
    end
  end

  describe '#bug_update' do
    it 'maps status/priority names to ids and forwards tags' do
      options = { slug: 'a', mode: 'production', status: 'closed', priority: 'major', tags: ['regression'] }

      expect(client).to receive(:invoke_tool).with(
        'update_bug',
        hash_including(slug: 'a', mode: 'production', number: 7,
                       status_id: 2, priority_id: 3, tags: ['regression'])
      ).and_return({})

      expect { described_class.new(options).bug_update(7) }.to output.to_stdout
    end
  end

  describe '#apm_groups' do
    it 'forwards the required metric and parses the --sort JSON object' do
      options = { slug: 'a', mode: 'production', metric: 'network',
                  sort: '{"by":"failure_rate","direction":"desc"}' }

      expect(client).to receive(:invoke_tool).with(
        'apm_list_groups',
        hash_including(slug: 'a', mode: 'production', metric: 'network',
                       sort: { 'by' => 'failure_rate', 'direction' => 'desc' })
      ).and_return({})

      expect { described_class.new(options).apm_groups }.to output.to_stdout
    end
  end

  describe '#apps_list' do
    it 'invokes list_applications without slug/mode' do
      expect(client).to receive(:invoke_tool).with('list_applications', hash_including(platform: 'ios'))
                                             .and_return({})

      expect { described_class.new({ platform: 'ios' }).apps_list }.to output.to_stdout
    end
  end
end
