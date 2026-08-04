# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Luciq::API::Client do
  let(:auth_token) { 'auth-token-123' }
  let(:slug) { 'test-app' }
  let(:mode) { 'production' }
  let(:base_url) { 'https://api.luciq.ai' }
  let(:client) { Luciq::API::Client.new }
  let(:file_path) { '/tmp/upload.zip' }

  before do
    ENV['LUCIQ_AUTH_TOKEN'] = auth_token
    ENV['LUCIQ_URL'] = base_url
    allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('bytes'))
  end

  describe '#whoami' do
    it 'returns user information on success' do
      stub_request(:get, "#{base_url}/api/cli/whoami")
        .with(headers: { 'Authorization' => auth_token })
        .to_return(status: 200, body: { email: 'dev@example.com', name: 'Developer' }.to_json)

      response = client.whoami

      expect(response['email']).to eq('dev@example.com')
      expect(response['name']).to eq('Developer')
    end

    it 'raises error on 401' do
      stub_request(:get, "#{base_url}/api/cli/whoami")
        .with(headers: { 'Authorization' => auth_token })
        .to_return(status: 401, body: { message: 'Authentication failed' }.to_json)

      expect { client.whoami }.to raise_error(RuntimeError, /401/)
    end
  end

  describe '#upload' do
    let(:endpoint) { 'ios-dsym' }
    let(:url) { "#{base_url}/api/cli/uploads/#{endpoint}" }

    it 'posts the file plus the given fields to the command endpoint with the auth token' do
      stub_request(:post, url).to_return(status: 200, body: { status: 'ok' }.to_json)

      client.upload(endpoint, file_path, slug: slug, mode: mode, version_name: '1.0.0')

      expect(
        a_request(:post, url).with(headers: { 'Authorization' => auth_token }) do |req|
          body = req.body
          body.include?('name="file"') &&
            body.match?(/name="slug"\r?\n\r?\ntest-app/) &&
            body.match?(/name="mode"\r?\n\r?\nproduction/) &&
            body.match?(/name="version_name"\r?\n\r?\n1\.0\.0/)
        end
      ).to have_been_made
    end

    it 'drops nil fields' do
      stub_request(:post, url).to_return(status: 200, body: '{}')

      client.upload(endpoint, file_path, slug: slug, mode: mode, codepush: nil)

      expect(a_request(:post, url) { |req| !req.body.include?('name="codepush"') }).to have_been_made
    end

    it 'raises on a non-success response' do
      stub_request(:post, url).to_return(status: 422, body: { error: 'nope' }.to_json)

      expect { client.upload(endpoint, file_path, slug: slug, mode: mode) }.to raise_error(RuntimeError, /422/)
    end

    it 'forwards version_code and a present codepush label' do
      stub_request(:post, url).to_return(status: 200, body: '{}')

      client.upload(endpoint, file_path, slug: slug, mode: mode, version_code: '42', codepush: 'v42')

      expect(
        a_request(:post, url).with do |req|
          req.body.match?(/name="version_code"\r?\n\r?\n42/) && req.body.match?(/name="codepush"\r?\n\r?\nv42/)
        end
      ).to have_been_made
    end

    {
      '/tmp/map.json' => 'application/json',
      '/tmp/map.txt' => 'text/plain',
      '/tmp/syms.zip' => 'application/octet-stream'
    }.each do |path, content_type|
      it "sets the file part content type to #{content_type} for a #{File.extname(path)} file" do
        allow(File).to receive(:open).with(path, 'rb').and_yield(StringIO.new('bytes'))
        stub_request(:post, url).to_return(status: 200, body: '{}')

        client.upload(endpoint, path, slug: slug, mode: mode)

        expect(
          a_request(:post, url).with do |req|
            req.body.match?(/name="file".*?Content-Type:\s*#{Regexp.escape(content_type)}/mi)
          end
        ).to have_been_made
      end
    end
  end
end
