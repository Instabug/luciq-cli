# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Luciq::Commands::Upload do
  let(:auth_token) { 'auth-token-123' }
  let(:app_token) { 'app-token-123' }
  let(:base_url) { 'https://api.luciq.ai' }
  let(:options) { { app_token: app_token, version_name: '1.0.0', version_code: '1' } }

  before do
    ENV['LUCIQ_AUTH_TOKEN'] = auth_token
    ENV['LUCIQ_URL'] = base_url
  end

  describe '#android_mapping' do
    let(:file_path) { '/tmp/mapping.zip' }
    let(:upload) { Luciq::Commands::Upload.new(options) }

    before do
      allow(File).to receive(:exist?).with(file_path).and_return(true)
      allow(File).to receive(:readable?).with(file_path).and_return(true)
    end

    context 'when file is valid' do
      before { allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake content')) }

      it 'uploads successfully' do
        stub_request(:post, "#{base_url}/api/web/public/mappings")
          .to_return(status: 200, body: { status: 'ok' }.to_json)

        expect { upload.android_mapping(file_path) }.to output(include('uploaded successfully')).to_stdout
      end

      it 'shows error on upload failure' do
        stub_request(:post, "#{base_url}/api/web/public/mappings")
          .to_return(status: 500, body: { error: 'Server error' }.to_json)

        expect { upload.android_mapping(file_path) }.to output(include('Upload failed')).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when file does not exist' do
      before { allow(File).to receive(:exist?).with(file_path).and_return(false) }

      it 'exits with error' do
        expect { upload.android_mapping(file_path) }.to output(include('File not found')).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when file is not readable' do
      before { allow(File).to receive(:readable?).with(file_path).and_return(false) }

      it 'exits with error' do
        expect { upload.android_mapping(file_path) }.to output(include('Cannot read file')).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when file is not a zip' do
      let(:file_path) { '/tmp/mapping.txt' }

      it 'exits with error' do
        expect { upload.android_mapping(file_path) }.to output(include('must be a .zip archive')).to_stdout.and raise_error(SystemExit)
      end
    end
  end

  describe '#react_native_sourcemap' do
    let(:file_path) { '/tmp/index.android.bundle.map' }
    let(:options) { { app_token: app_token } }
    let(:upload) { Luciq::Commands::Upload.new(options) }

    before do
      allow(File).to receive(:exist?).with(file_path).and_return(true)
      allow(File).to receive(:readable?).with(file_path).and_return(true)
    end

    context 'when file is valid with minimal options' do
      before { allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake sourcemap')) }

      it 'uploads successfully' do
        stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
          .to_return(status: 200, body: { status: 'ok' }.to_json)

        expect { upload.react_native_sourcemap(file_path) }.to output(include('uploaded successfully')).to_stdout
      end

      it 'shows error on upload failure' do
        stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
          .to_return(status: 500, body: { error: 'Server error' }.to_json)

        expect { upload.react_native_sourcemap(file_path) }.to output(include('Upload failed')).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when file is valid with all options' do
      let(:options) do
        {
          app_token: app_token,
          os: 'android',
          version_name: '2.0.0',
          version_code: '10',
          codepush: 'v5',
          app_variant: 'prod'
        }
      end

      before { allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake sourcemap')) }

      it 'uploads successfully with app_version' do
        stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
          .to_return(status: 200, body: { status: 'ok' }.to_json)

        expect { upload.react_native_sourcemap(file_path) }.to output(include('uploaded successfully')).to_stdout
      end
    end

    context 'when file does not exist' do
      before { allow(File).to receive(:exist?).with(file_path).and_return(false) }

      it 'exits with error' do
        expect { upload.react_native_sourcemap(file_path) }.to output(include('File not found')).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when file is not readable' do
      before { allow(File).to receive(:readable?).with(file_path).and_return(false) }

      it 'exits with error' do
        expect { upload.react_native_sourcemap(file_path) }.to output(include('Cannot read file')).to_stdout.and raise_error(SystemExit)
      end
    end
  end
end

