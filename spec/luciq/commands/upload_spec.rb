# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Luciq::Commands::Upload do
  let(:auth_token) { 'auth-token-123' }
  let(:base_url) { 'https://api.luciq.ai' }

  before do
    ENV['LUCIQ_AUTH_TOKEN'] = auth_token
    ENV['LUCIQ_URL'] = base_url
  end

  def stub_present_file(path)
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:readable?).and_return(true)
    allow(File).to receive(:open).with(path, 'rb').and_yield(StringIO.new('bytes'))
  end

  APP = { slug: 'test-app', mode: 'production' }.freeze
  VERSIONS = { version_code: '1', version_name: '1.0.0' }.freeze

  # method => [endpoint, options, format]  (format: :zip | :sourcemap | :none)
  COMMANDS = {
    ios_dsym: ['ios-dsym', APP, :zip],
    android_mapping: ['android-mapping', APP.merge(VERSIONS), :none],
    android_ndk: ['android-ndk', APP.merge(version_name: '1.0.0', arch: 'arm64-v8a'), :zip],
    react_native_ios_dsym: ['react-native-ios-dsym', APP, :zip],
    react_native_ios_sourcemap: ['react-native-ios-sourcemap', APP.merge(VERSIONS), :sourcemap],
    react_native_android_mapping: ['react-native-android-mapping', APP.merge(VERSIONS), :none],
    react_native_android_sourcemap: ['react-native-android-sourcemap', APP.merge(VERSIONS), :sourcemap],
    react_native_ndk: ['react-native-ndk', APP.merge(version_name: '1.0.0', arch: 'x86'), :zip],
    flutter_ios_dsym: ['flutter-ios-dsym', APP, :zip],
    flutter_ios_sourcemap: ['flutter-ios-sourcemap', APP.merge(VERSIONS), :zip],
    flutter_android_mapping: ['flutter-android-mapping', APP.merge(VERSIONS), :none],
    flutter_android_sourcemap: ['flutter-android-sourcemap', APP.merge(VERSIONS), :zip],
    flutter_ndk: ['flutter-ndk', APP.merge(version_name: '1.0.0', arch: 'x86_64'), :zip]
  }.freeze

  VALID_EXT = { zip: '.zip', sourcemap: '.json', none: '.txt' }.freeze
  BAD_EXT = { zip: '.txt', sourcemap: '.zip' }.freeze
  FORMAT_ERROR = { zip: 'must be a .zip archive', sourcemap: 'must be a .json or .txt file' }.freeze

  COMMANDS.each do |method, (endpoint, options, format)|
    describe "##{method}" do
      let(:file_path) { "/tmp/upload#{VALID_EXT[format]}" }
      let(:upload) { described_class.new(options) }
      let(:url) { "#{base_url}/api/cli/uploads/#{endpoint}" }

      before { stub_present_file(file_path) }

      it 'uploads successfully' do
        stub_request(:post, url).to_return(status: 200, body: { status: 'ok' }.to_json)

        expect { upload.public_send(method, file_path) }.to output(include('uploaded successfully')).to_stdout
      end

      it 'shows an error and exits on upload failure' do
        stub_request(:post, url).to_return(status: 500, body: { error: 'Server error' }.to_json)

        expect { upload.public_send(method, file_path) }
          .to output(include('Upload failed')).to_stdout.and raise_error(SystemExit)
      end

      it 'exits when the file does not exist' do
        allow(File).to receive(:exist?).and_return(false)

        expect { upload.public_send(method, file_path) }
          .to output(include('File not found')).to_stdout.and raise_error(SystemExit)
      end

      it 'exits when the file is not readable' do
        allow(File).to receive(:readable?).and_return(false)

        expect { upload.public_send(method, file_path) }
          .to output(include('Cannot read file')).to_stdout.and raise_error(SystemExit)
      end

      if format != :none
        it 'exits when the file extension is wrong' do
          bad_path = "/tmp/upload#{BAD_EXT[format]}"
          allow(File).to receive(:open).with(bad_path, 'rb').and_yield(StringIO.new('bytes'))

          expect { upload.public_send(method, bad_path) }
            .to output(include(FORMAT_ERROR[format])).to_stdout.and raise_error(SystemExit)
        end
      end

      if options.key?(:arch)
        it 'exits when the architecture is invalid' do
          bad = described_class.new(options.merge(arch: 'mips'))

          expect { bad.public_send(method, file_path) }
            .to output(include('Invalid architecture')).to_stdout.and raise_error(SystemExit)
        end
      end
    end
  end

  describe 'forwarding the CLI options to the request body' do
    let(:options) { APP.merge(version_name: '1.0.0', arch: 'arm64-v8a') }
    let(:upload) { described_class.new(options) }
    let(:file_path) { '/tmp/upload.zip' }
    let(:url) { "#{base_url}/api/cli/uploads/android-ndk" }

    before { stub_present_file(file_path) }

    it 'sends every option through to the server as a multipart field' do
      stub_request(:post, url).to_return(status: 200, body: { status: 'ok' }.to_json)

      upload.android_ndk(file_path)

      expect(
        a_request(:post, url).with do |req|
          body = req.body
          body.match?(/name="slug"\r?\n\r?\ntest-app/) &&
            body.match?(/name="mode"\r?\n\r?\nproduction/) &&
            body.match?(/name="version_name"\r?\n\r?\n1\.0\.0/) &&
            body.match?(/name="arch"\r?\n\r?\narm64-v8a/)
        end
      ).to have_been_made
    end
  end
end
