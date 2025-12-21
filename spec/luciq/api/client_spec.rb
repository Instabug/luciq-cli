# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Luciq::API::Client do
  let(:auth_token) { 'auth-token-123' }
  let(:app_token) { 'app-token-123' }
  let(:base_url) { 'https://api.luciq.ai' }
  let(:client) { Luciq::API::Client.new }

  before do
    ENV['LUCIQ_AUTH_TOKEN'] = auth_token
    ENV['LUCIQ_URL'] = base_url
  end

  describe '#whoami' do
    it 'returns user information on success' do
      stub_request(:get, "#{base_url}/api/web/public/cli/whoami")
        .with(headers: { 'Authorization' => auth_token })
        .to_return(status: 200, body: { email: 'dev@example.com', name: 'Developer' }.to_json)

      response = client.whoami

      expect(response['email']).to eq('dev@example.com')
      expect(response['name']).to eq('Developer')
    end

    it 'raises error on 401' do
      stub_request(:get, "#{base_url}/api/web/public/cli/whoami")
        .with(headers: { 'Authorization' => auth_token })
        .to_return(status: 401, body: { message: 'Authentication failed' }.to_json)

      expect { client.whoami }.to raise_error(RuntimeError, /401/)
    end
  end

  describe '#upload_android_mapping' do
    let(:file_path) { '/tmp/mapping.zip' }

    before do
      allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake content'))
    end

    it 'uploads mapping file successfully' do
      stub_request(:post, "#{base_url}/api/web/public/mappings")
        .to_return(status: 200, body: { status: 'ok' }.to_json)

      response = client.upload_android_mapping(
        file_path: file_path,
        app_token: app_token,
        version_code: '1',
        version_name: '1.0.0'
      )

      expect(response['status']).to eq('ok')
    end

    it 'raises error on invalid zip' do
      stub_request(:post, "#{base_url}/api/web/public/mappings")
        .to_return(status: 400, body: { error: 'invalid zip file' }.to_json)

      expect do
        client.upload_android_mapping(
          file_path: file_path, app_token: app_token,
          version_code: '1', version_name: '1.0.0'
        )
      end.to raise_error(RuntimeError, /400/)
    end
  end
end
