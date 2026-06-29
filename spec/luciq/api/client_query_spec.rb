# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Luciq::API::Client, 'query endpoints' do
  let(:auth_token) { 'auth-token-123' }
  let(:base_url) { 'https://api.luciq.ai' }
  let(:client) { Luciq::API::Client.new }

  before do
    ENV['LUCIQ_AUTH_TOKEN'] = auth_token
    ENV['LUCIQ_URL'] = base_url
  end

  describe '#invoke_tool' do
    it 'POSTs JSON arguments to the tool endpoint and returns the parsed body' do
      stub_request(:post, "#{base_url}/api/cli/tools/list_crashes")
        .with(
          headers: { 'Authorization' => auth_token, 'Content-Type' => 'application/json' },
          body: { slug: 'my-app', mode: 'production' }.to_json
        )
        .to_return(status: 200, body: { crashes: [] }.to_json)

      response = client.invoke_tool('list_crashes', { slug: 'my-app', mode: 'production' })

      expect(response).to eq('crashes' => [])
    end

    it 'raises on an error response' do
      stub_request(:post, "#{base_url}/api/cli/tools/list_crashes")
        .to_return(status: 422, body: { error: 'bad request' }.to_json)

      expect { client.invoke_tool('list_crashes', { slug: 'x', mode: 'production' }) }
        .to raise_error(RuntimeError, /422/)
    end
  end
end
