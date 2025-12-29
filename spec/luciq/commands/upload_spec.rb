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
  end

  describe '#react_native_ios' do
    let(:file_path) { '/tmp/dsyms.zip' }
    let(:options) { { app_token: app_token } }
    let(:upload) { Luciq::Commands::Upload.new(options) }

    before do
      allow(File).to receive(:exist?).with(file_path).and_return(true)
      allow(File).to receive(:readable?).with(file_path).and_return(true)
    end

    context 'when file is valid' do
      before { allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake dsym')) }

      it 'uploads successfully' do
        stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
          .to_return(status: 200, body: { status: 'ok' }.to_json)

        expect { upload.react_native_ios(file_path) }.to output(include('uploaded successfully')).to_stdout
      end

      it 'shows error on upload failure' do
        stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
          .to_return(status: 500, body: { error: 'Server error' }.to_json)

        expect { upload.react_native_ios(file_path) }.to output(include('Upload failed')).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when file does not exist' do
      before { allow(File).to receive(:exist?).with(file_path).and_return(false) }

      it 'exits with error' do
        expect { upload.react_native_ios(file_path) }.to output(include('File not found')).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when file is not readable' do
      before { allow(File).to receive(:readable?).with(file_path).and_return(false) }

      it 'exits with error' do
        expect { upload.react_native_ios(file_path) }.to output(include('Cannot read file')).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when file is not a zip' do
      let(:file_path) { '/tmp/dsyms.txt' }

      it 'exits with error' do
        expect { upload.react_native_ios(file_path) }.to output(include('must be a .zip archive')).to_stdout.and raise_error(SystemExit)
      end
    end
  end

  describe '#react_native_android' do
    let(:file_path) { '/tmp/android-sourcemap.txt' }
    let(:options) { { app_token: app_token, version_code: '1', version_name: '1.0.0' } }
    let(:upload) { Luciq::Commands::Upload.new(options) }

    before do
      allow(File).to receive(:exist?).with(file_path).and_return(true)
      allow(File).to receive(:readable?).with(file_path).and_return(true)
    end

    context 'when file is valid' do
      before { allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake sourcemap')) }

      it 'uploads successfully' do
        stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
          .to_return(status: 200, body: { status: 'ok' }.to_json)

        expect { upload.react_native_android(file_path) }.to output(include('uploaded successfully')).to_stdout
      end

      it 'shows error on upload failure' do
        stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
          .to_return(status: 500, body: { error: 'Server error' }.to_json)

        expect { upload.react_native_android(file_path) }.to output(include('Upload failed')).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when file does not exist' do
      before { allow(File).to receive(:exist?).with(file_path).and_return(false) }

      it 'exits with error' do
        expect { upload.react_native_android(file_path) }.to output(include('File not found')).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when file is not readable' do
      before { allow(File).to receive(:readable?).with(file_path).and_return(false) }

      it 'exits with error' do
        expect { upload.react_native_android(file_path) }.to output(include('Cannot read file')).to_stdout.and raise_error(SystemExit)
      end
    end
  end

  describe '#ios_dsym' do
    let(:file_path) { '/tmp/dsym.zip' }
    let(:options) { { app_token: app_token } }
    let(:upload) { Luciq::Commands::Upload.new(options) }

    before do
      allow(File).to receive(:exist?).with(file_path).and_return(true)
      allow(File).to receive(:readable?).with(file_path).and_return(true)
    end

    context 'when file is valid with minimal options' do
      before { allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake dsym')) }

      it 'uploads successfully' do
        stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
          .to_return(status: 200, body: { status: 'ok' }.to_json)

        expect { upload.ios_dsym(file_path) }.to output(include('uploaded successfully')).to_stdout
      end

      it 'shows error on upload failure' do
        stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
          .to_return(status: 500, body: { error: 'Server error' }.to_json)

        expect { upload.ios_dsym(file_path) }.to output(include('Upload failed')).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when file does not exist' do
      before { allow(File).to receive(:exist?).with(file_path).and_return(false) }

      it 'exits with error' do
        expect { upload.ios_dsym(file_path) }.to output(include('File not found')).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when file is not readable' do
      before { allow(File).to receive(:readable?).with(file_path).and_return(false) }

      it 'exits with error' do
        expect { upload.ios_dsym(file_path) }.to output(include('Cannot read file')).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when file is not a dsym zip' do
      let(:file_path) { '/tmp/dsym.txt' }

      it 'exits with error' do
        expect { upload.ios_dsym(file_path) }.to output(include('must be a .zip archive')).to_stdout.and raise_error(SystemExit)
      end
    end
  end

  describe '#flutter_ios_dsym' do
    let(:file_path) { '/tmp/flutter.dSYM.zip' }
    let(:options) { { app_token: app_token } }
    let(:upload) { Luciq::Commands::Upload.new(options) }

    before do
      allow(File).to receive(:exist?).with(file_path).and_return(true)
      allow(File).to receive(:readable?).with(file_path).and_return(true)
    end

    context 'when file is valid' do
      before { allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake dsym')) }

      it 'uploads successfully' do
        stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
          .to_return(status: 200, body: { status: 'ok' }.to_json)

        expect { upload.flutter_ios_dsym(file_path) }.to output(include('uploaded successfully')).to_stdout
      end

      it 'shows error on upload failure' do
        stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
          .to_return(status: 500, body: { error: 'Server error' }.to_json)

        expect { upload.flutter_ios_dsym(file_path) }.to output(include('Upload failed')).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when file does not exist' do
      before { allow(File).to receive(:exist?).with(file_path).and_return(false) }

      it 'exits with error' do
        expect { upload.flutter_ios_dsym(file_path) }.to output(include('File not found')).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when file is not a zip' do
      let(:file_path) { '/tmp/flutter.dSYM.txt' }

      it 'exits with error' do
        expect { upload.flutter_ios_dsym(file_path) }.to output(include('must be a .zip archive')).to_stdout.and raise_error(SystemExit)
      end
    end
  end

  describe '#flutter_android_mapping' do
    let(:file_path) { '/tmp/flutter-mapping.txt' }
    let(:options) { { app_token: app_token, version_name: '1.0.0', version_code: '1' } }
    let(:upload) { Luciq::Commands::Upload.new(options) }

    before do
      allow(File).to receive(:exist?).with(file_path).and_return(true)
      allow(File).to receive(:readable?).with(file_path).and_return(true)
    end

    context 'when file is valid' do
      before { allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake mapping')) }

      it 'uploads successfully' do
        stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
          .to_return(status: 200, body: { status: 'ok' }.to_json)

        expect { upload.flutter_android_mapping(file_path) }.to output(include('uploaded successfully')).to_stdout
      end

      it 'shows error on upload failure' do
        stub_request(:post, "#{base_url}/api/sdk/v3/symbols_files")
          .to_return(status: 500, body: { error: 'Server error' }.to_json)

        expect { upload.flutter_android_mapping(file_path) }.to output(include('Upload failed')).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when file does not exist' do
      before { allow(File).to receive(:exist?).with(file_path).and_return(false) }

      it 'exits with error' do
        expect { upload.flutter_android_mapping(file_path) }.to output(include('File not found')).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when file is not readable' do
      before { allow(File).to receive(:readable?).with(file_path).and_return(false) }

      it 'exits with error' do
        expect { upload.flutter_android_mapping(file_path) }.to output(include('Cannot read file')).to_stdout.and raise_error(SystemExit)
      end
    end
  end

  describe '#flutter_ios_sourcemap' do
    let(:file_path) { '/tmp/flutter-ios.symbols.zip' }
    let(:options) { { app_token: app_token, version_name: '1.0.0', version_code: '1' } }
    let(:upload) { Luciq::Commands::Upload.new(options) }

    before do
      allow(File).to receive(:exist?).with(file_path).and_return(true)
      allow(File).to receive(:readable?).with(file_path).and_return(true)
    end

    context 'when file is valid' do
      before { allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake symbols')) }

      it 'uploads successfully' do
        stub_request(:post, "#{base_url}/api/web/public/flutter-symbol-files/ios")
          .to_return(status: 200, body: { status: 'ok' }.to_json)

        expect { upload.flutter_ios_sourcemap(file_path) }.to output(include('uploaded successfully')).to_stdout
      end

      it 'shows error on upload failure' do
        stub_request(:post, "#{base_url}/api/web/public/flutter-symbol-files/ios")
          .to_return(status: 500, body: { error: 'Server error' }.to_json)

        expect { upload.flutter_ios_sourcemap(file_path) }.to output(include('Upload failed')).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when file does not exist' do
      before { allow(File).to receive(:exist?).with(file_path).and_return(false) }

      it 'exits with error' do
        expect { upload.flutter_ios_sourcemap(file_path) }.to output(include('File not found')).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when file is not a zip' do
      let(:file_path) { '/tmp/flutter-ios.symbols.txt' }

      it 'exits with error' do
        expect { upload.flutter_ios_sourcemap(file_path) }.to output(include('must be a .zip archive')).to_stdout.and raise_error(SystemExit)
      end
    end
  end

  describe '#flutter_android_sourcemap' do
    let(:file_path) { '/tmp/flutter-android.symbols.zip' }
    let(:options) { { app_token: app_token } }
    let(:upload) { Luciq::Commands::Upload.new(options) }

    before do
      allow(File).to receive(:exist?).with(file_path).and_return(true)
      allow(File).to receive(:readable?).with(file_path).and_return(true)
    end

    context 'when file is valid' do
      before { allow(File).to receive(:open).with(file_path, 'rb').and_yield(StringIO.new('fake symbols')) }

      it 'uploads successfully' do
        stub_request(:post, "#{base_url}/api/web/public/flutter-symbol-files/android")
          .to_return(status: 200, body: { status: 'ok' }.to_json)

        expect { upload.flutter_android_sourcemap(file_path) }.to output(include('uploaded successfully')).to_stdout
      end

      it 'shows error on upload failure' do
        stub_request(:post, "#{base_url}/api/web/public/flutter-symbol-files/android")
          .to_return(status: 500, body: { error: 'Server error' }.to_json)

        expect { upload.flutter_android_sourcemap(file_path) }.to output(include('Upload failed')).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when file does not exist' do
      before { allow(File).to receive(:exist?).with(file_path).and_return(false) }

      it 'exits with error' do
        expect { upload.flutter_android_sourcemap(file_path) }.to output(include('File not found')).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when file is not a zip' do
      let(:file_path) { '/tmp/flutter-android.symbols.txt' }

      it 'exits with error' do
        expect { upload.flutter_android_sourcemap(file_path) }.to output(include('must be a .zip archive')).to_stdout.and raise_error(SystemExit)
      end
    end
  end
end

