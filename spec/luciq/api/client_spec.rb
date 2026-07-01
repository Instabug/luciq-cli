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

  describe '#upload_ios_dsym' do
    let(:file_path) { '/tmp/dsym.zip' }

    before do
      allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake dsym'))
    end

    it 'uploads dsym successfully' do
      stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
        .to_return(status: 200, body: { status: 'ok' }.to_json)

      response = client.upload_ios_dsym(
        file_path: file_path,
        app_token: app_token
      )

      expect(response['status']).to eq('ok')
    end

    it 'posts symbols_file with os=ios' do
      stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
        .to_return(status: 200, body: { status: 'ok' }.to_json)

      client.upload_ios_dsym(file_path: file_path, app_token: app_token)

      expect(
        a_request(:post, "#{base_url}/api/sdk/v3/symbols_files").with do |req|
          req.body.include?('name="symbols_file"') && req.body.match?(/name="os"\r?\n\r?\nios/)
        end
      ).to have_been_made
    end

    it 'raises error on failure' do
      stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
        .to_return(status: 400, body: { error: 'invalid zip file' }.to_json)

      expect do
        client.upload_ios_dsym(
          file_path: file_path,
          app_token: app_token
        )
      end.to raise_error(RuntimeError, /400/)
    end
  end

  describe '#upload_android_mapping' do
    let(:file_path) { '/tmp/mapping.txt' }

    before do
      allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake content'))
    end

    it 'uploads mapping file successfully' do
      stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
        .to_return(status: 200, body: { status: 'ok' }.to_json)

      response = client.upload_android_mapping(
        file_path: file_path,
        app_token: app_token,
        version_code: '1',
        version_name: '1.0.0'
      )

      expect(response['status']).to eq('ok')
    end

    it 'posts symbols_file with os=android and app_version json' do
      stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
        .to_return(status: 200, body: { status: 'ok' }.to_json)

      client.upload_android_mapping(file_path: file_path, app_token: app_token, version_code: '1', version_name: '1.0.0')

      expect(
        a_request(:post, "#{base_url}/api/sdk/v3/symbols_files").with do |req|
          req.body.include?('name="symbols_file"') &&
            req.body.match?(/name="os"\r?\n\r?\nandroid/) &&
            req.body.include?('{"code":"1","name":"1.0.0"}')
        end
      ).to have_been_made
    end

    it 'raises error on failure' do
      stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
        .to_return(status: 400, body: { error: 'Bad request parameters' }.to_json)

      expect do
        client.upload_android_mapping(
          file_path: file_path, app_token: app_token,
          version_code: '1', version_name: '1.0.0'
        )
      end.to raise_error(RuntimeError, /400/)
    end
  end

  describe '#upload_android_ndk' do
    let(:file_path) { '/tmp/so-files.zip' }

    before do
      allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake so'))
    end

    it 'uploads .so files successfully' do
      stub_request(:post, "#{base_url}/api/web/public/so_files")
        .to_return(status: 200, body: {}.to_json)

      response = client.upload_android_ndk(
        file_path: file_path,
        app_token: app_token,
        app_version: '1.0.0',
        arch: 'arm64-v8a'
      )

      expect(response).to eq({})
    end

    it 'posts so_file with arch and app_version name' do
      stub_request(:post, "#{base_url}/api/web/public/so_files")
        .to_return(status: 200, body: {}.to_json)

      client.upload_android_ndk(file_path: file_path, app_token: app_token, app_version: '1.0.0', arch: 'arm64-v8a')

      expect(
        a_request(:post, "#{base_url}/api/web/public/so_files").with do |req|
          req.body.include?('name="so_file"') &&
            req.body.match?(/name="arch"\r?\n\r?\narm64-v8a/) &&
            req.body.match?(/name="app_version"\r?\n\r?\n1\.0\.0/)
        end
      ).to have_been_made
    end

    it 'raises error on failure' do
      stub_request(:post, "#{base_url}/api/web/public/so_files")
        .to_return(status: 400, body: { error: 'invalid arch' }.to_json)

      expect do
        client.upload_android_ndk(
          file_path: file_path, app_token: app_token, app_version: '1.0.0', arch: 'arm64-v8a'
        )
      end.to raise_error(RuntimeError, /400/)
    end
  end

  describe '#upload_react_native_ios_dsym' do
    let(:file_path) { '/tmp/dsyms.zip' }

    before do
      allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake dsym'))
    end

    it 'uploads dsym successfully' do
      stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
        .to_return(status: 200, body: { status: 'ok' }.to_json)

      response = client.upload_react_native_ios_dsym(
        file_path: file_path,
        app_token: app_token
      )

      expect(response['status']).to eq('ok')
    end

    it 'raises error on failure' do
      stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
        .to_return(status: 400, body: { error: 'invalid dsym' }.to_json)

      expect do
        client.upload_react_native_ios_dsym(
          file_path: file_path,
          app_token: app_token
        )
      end.to raise_error(RuntimeError, /400/)
    end
  end

  describe '#upload_react_native_ios_sourcemap' do
    let(:file_path) { '/tmp/ios-sourcemap.json' }

    before do
      allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake sourcemap'))
    end

    it 'uploads source map successfully' do
      stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
        .to_return(status: 200, body: { status: 'ok' }.to_json)

      response = client.upload_react_native_ios_sourcemap(
        file_path: file_path,
        app_token: app_token,
        app_version: { code: '1', name: '1.0.0' }
      )

      expect(response['status']).to eq('ok')
    end

    it 'posts symbols_file with platform=react_native and os=ios' do
      stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
        .to_return(status: 200, body: { status: 'ok' }.to_json)

      client.upload_react_native_ios_sourcemap(file_path: file_path, app_token: app_token, app_version: { code: '1', name: '1.0.0' })

      expect(
        a_request(:post, "#{base_url}/api/sdk/v3/symbols_files").with do |req|
          req.body.include?('name="symbols_file"') &&
            req.body.match?(/name="platform"\r?\n\r?\nreact_native/) &&
            req.body.match?(/name="os"\r?\n\r?\nios/)
        end
      ).to have_been_made
    end

    it 'raises error on failure' do
      stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
        .to_return(status: 400, body: { error: 'invalid source map' }.to_json)

      expect do
        client.upload_react_native_ios_sourcemap(
          file_path: file_path, app_token: app_token, app_version: { code: '1', name: '1.0.0' }
        )
      end.to raise_error(RuntimeError, /400/)
    end
  end

  describe '#upload_react_native_android_mapping' do
    let(:file_path) { '/tmp/android-mapping.txt' }

    before do
      allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake mapping'))
    end

    it 'uploads mapping successfully' do
      stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
        .to_return(status: 200, body: { status: 'ok' }.to_json)

      response = client.upload_react_native_android_mapping(
        file_path: file_path,
        app_token: app_token,
        version_code: '1',
        version_name: '1.0.0'
      )

      expect(response['status']).to eq('ok')
    end

    it 'raises error on failure' do
      stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
        .to_return(status: 400, body: { error: 'invalid mapping' }.to_json)

      expect do
        client.upload_react_native_android_mapping(
          file_path: file_path,
          app_token: app_token,
          version_code: '1',
          version_name: '1.0.0'
        )
      end.to raise_error(RuntimeError, /400/)
    end
  end

  describe '#upload_react_native_android_sourcemap' do
    let(:file_path) { '/tmp/android-sourcemap.json' }

    before do
      allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake sourcemap'))
    end

    it 'uploads source map successfully' do
      stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
        .to_return(status: 200, body: { status: 'ok' }.to_json)

      response = client.upload_react_native_android_sourcemap(
        file_path: file_path,
        app_token: app_token,
        app_version: { code: '1', name: '1.0.0' }
      )

      expect(response['status']).to eq('ok')
    end

    it 'uploads source map with codepush label' do
      stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
        .to_return(status: 200, body: { status: 'ok' }.to_json)

      response = client.upload_react_native_android_sourcemap(
        file_path: file_path,
        app_token: app_token,
        app_version: { code: '10', name: '2.0.0', codepush: 'v5' }
      )

      expect(response['status']).to eq('ok')
      expect(
        a_request(:post, "#{base_url}/api/sdk/v3/symbols_files").with do |req|
          req.body.include?('"codepush":"v5"')
        end
      ).to have_been_made
    end

    it 'raises error on failure' do
      stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
        .to_return(status: 400, body: { error: 'invalid source map' }.to_json)

      expect do
        client.upload_react_native_android_sourcemap(
          file_path: file_path, app_token: app_token, app_version: { code: '1', name: '1.0.0' }
        )
      end.to raise_error(RuntimeError, /400/)
    end
  end

  describe '#upload_react_native_ndk' do
    let(:file_path) { '/tmp/so-files.zip' }

    before do
      allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake so'))
    end

    it 'uploads .so files successfully' do
      stub_request(:post, "#{base_url}/api/web/public/so_files")
        .to_return(status: 200, body: {}.to_json)

      response = client.upload_react_native_ndk(
        file_path: file_path,
        app_token: app_token,
        app_version: '1.0.0',
        arch: 'arm64-v8a'
      )

      expect(response).to eq({})
    end

    it 'raises error on failure' do
      stub_request(:post, "#{base_url}/api/web/public/so_files")
        .to_return(status: 400, body: { error: 'invalid arch' }.to_json)

      expect do
        client.upload_react_native_ndk(
          file_path: file_path, app_token: app_token, app_version: '1.0.0', arch: 'arm64-v8a'
        )
      end.to raise_error(RuntimeError, /400/)
    end
  end

  describe '#upload_flutter_ios_dsym' do
    let(:file_path) { '/tmp/flutter.dSYM.zip' }

    before do
      allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake dsym'))
    end

    it 'uploads dsym successfully' do
      stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
        .to_return(status: 200, body: { status: 'ok' }.to_json)

      response = client.upload_flutter_ios_dsym(
        file_path: file_path,
        app_token: app_token
      )

      expect(response['status']).to eq('ok')
    end

    it 'raises error on failure' do
      stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
        .to_return(status: 400, body: { error: 'invalid zip file' }.to_json)

      expect do
        client.upload_flutter_ios_dsym(
          file_path: file_path,
          app_token: app_token
        )
      end.to raise_error(RuntimeError, /400/)
    end
  end

  describe '#upload_flutter_ios_sourcemap' do
    let(:file_path) { '/tmp/flutter-ios.symbols.zip' }

    before do
      allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake symbols'))
    end

    it 'uploads sourcemap successfully' do
      stub_request(:post, "#{base_url}/api/web/public/flutter-symbol-files/ios")
        .to_return(status: 200, body: { status: 'ok' }.to_json)

      response = client.upload_flutter_ios_sourcemap(
        file_path: file_path,
        app_token: app_token,
        version_name: '1.0.0',
        version_code: '1'
      )

      expect(response['status']).to eq('ok')
    end

    it 'posts file with app_version_name and app_version_code' do
      stub_request(:post, "#{base_url}/api/web/public/flutter-symbol-files/ios")
        .to_return(status: 200, body: { status: 'ok' }.to_json)

      client.upload_flutter_ios_sourcemap(file_path: file_path, app_token: app_token, version_name: '1.0.0', version_code: '1')

      expect(
        a_request(:post, "#{base_url}/api/web/public/flutter-symbol-files/ios").with do |req|
          req.body.include?('name="file"') &&
            req.body.match?(/name="app_version_name"\r?\n\r?\n1\.0\.0/) &&
            req.body.match?(/name="app_version_code"\r?\n\r?\n1/)
        end
      ).to have_been_made
    end

    it 'raises error on failure' do
      stub_request(:post, "#{base_url}/api/web/public/flutter-symbol-files/ios")
        .to_return(status: 400, body: { error: 'invalid zip file' }.to_json)

      expect do
        client.upload_flutter_ios_sourcemap(
          file_path: file_path,
          app_token: app_token,
          version_name: '1.0.0',
          version_code: '1'
        )
      end.to raise_error(RuntimeError, /400/)
    end
  end

  describe '#upload_flutter_android_mapping' do
    let(:file_path) { '/tmp/flutter-mapping.txt' }

    before do
      allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake mapping'))
    end

    it 'uploads mapping file successfully' do
      stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
        .to_return(status: 200, body: { status: 'ok' }.to_json)

      response = client.upload_flutter_android_mapping(
        file_path: file_path,
        app_token: app_token,
        version_code: '1',
        version_name: '1.0.0'
      )

      expect(response['status']).to eq('ok')
    end

    it 'raises error on failure' do
      stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
        .to_return(status: 400, body: { error: 'invalid file' }.to_json)

      expect do
        client.upload_flutter_android_mapping(
          file_path: file_path,
          app_token: app_token,
          version_code: '1',
          version_name: '1.0.0'
        )
      end.to raise_error(RuntimeError, /400/)
    end
  end

  describe '#upload_flutter_android_sourcemap' do
    let(:file_path) { '/tmp/flutter-android.symbols.zip' }

    before do
      allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake symbols'))
    end

    it 'uploads sourcemap successfully' do
      stub_request(:post, "#{base_url}/api/web/public/flutter-symbol-files/android")
        .to_return(status: 200, body: { status: 'ok' }.to_json)

      response = client.upload_flutter_android_sourcemap(
        file_path: file_path,
        app_token: app_token,
        version_name: '1.0.0',
        version_code: '1'
      )

      expect(response['status']).to eq('ok')
    end

    it 'raises error on failure' do
      stub_request(:post, "#{base_url}/api/web/public/flutter-symbol-files/android")
        .to_return(status: 400, body: { error: 'invalid zip file' }.to_json)

      expect do
        client.upload_flutter_android_sourcemap(
          file_path: file_path,
          app_token: app_token,
          version_name: '1.0.0',
          version_code: '1'
        )
      end.to raise_error(RuntimeError, /400/)
    end
  end

  describe '#upload_flutter_ndk' do
    let(:file_path) { '/tmp/so-files.zip' }

    before do
      allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake so'))
    end

    it 'uploads .so files successfully' do
      stub_request(:post, "#{base_url}/api/web/public/so_files")
        .to_return(status: 200, body: {}.to_json)

      response = client.upload_flutter_ndk(
        file_path: file_path,
        app_token: app_token,
        app_version: '1.0.0',
        arch: 'arm64-v8a'
      )

      expect(response).to eq({})
    end

    it 'raises error on failure' do
      stub_request(:post, "#{base_url}/api/web/public/so_files")
        .to_return(status: 400, body: { error: 'invalid arch' }.to_json)

      expect do
        client.upload_flutter_ndk(
          file_path: file_path, app_token: app_token, app_version: '1.0.0', arch: 'arm64-v8a'
        )
      end.to raise_error(RuntimeError, /400/)
    end
  end
end
