# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Luciq::Commands::Auth do
  let(:auth_token) { 'auth-token-123' }
  let(:base_url) { 'https://api.luciq.ai' }

  before do
    ENV['LUCIQ_AUTH_TOKEN'] = auth_token
    ENV['LUCIQ_URL'] = base_url
  end

  describe '#login' do
    context 'with --auth-token option' do
      it 'saves token without prompting' do
        auth = Luciq::Commands::Auth.new(auth_token: 'my-token')
        expect(Luciq::Config).to receive(:save_token).with('my-token')

        expect { auth.login }.to output(include('Token saved')).to_stdout
      end
    end

    context 'with stdin input' do
      it 'prompts and saves token' do
        auth = Luciq::Commands::Auth.new
        allow($stdin).to receive(:gets).and_return("stdin-token\n")
        expect(Luciq::Config).to receive(:save_token).with('stdin-token')

        expect { auth.login }.to output(include('Paste your CLI token', 'Token saved')).to_stdout
      end
    end

    context 'with empty token' do
      it 'exits with error' do
        auth = Luciq::Commands::Auth.new(auth_token: '')

        expect { auth.login }.to output(include('No token provided')).to_stdout.and raise_error(SystemExit)
      end
    end
  end

  describe '#whoami' do
    let(:auth) { Luciq::Commands::Auth.new }

    context 'when token is provided' do
      it 'displays user information' do
        stub_request(:get, "#{base_url}/api/cli/whoami")
          .to_return(status: 200, body: { email: 'dev@example.com', name: 'Developer' }.to_json)

        expect { auth.whoami }.to output(include('dev@example.com', 'Developer')).to_stdout
      end

      it 'shows error for invalid token' do
        stub_request(:get, "#{base_url}/api/cli/whoami")
          .to_return(status: 401, body: { message: 'Authentication failed' }.to_json)

        expect { auth.whoami }.to output(include('Authentication failed')).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when token is not provided' do
      # A blank token reads as unauthenticated without falling through to ~/.luciqrc (see Config.load_token).
      before { ENV['LUCIQ_AUTH_TOKEN'] = '' }

      it 'prompts to login' do
        expect { auth.whoami }.to output(include('Not authenticated. Run: luciq login')).to_stdout.and raise_error(SystemExit)
      end
    end
  end

  describe '#logout' do
    let(:auth) { Luciq::Commands::Auth.new }

    it 'clears the token' do
      expect(Luciq::Config).to receive(:clear_token)

      expect { auth.logout }.to output(include('Logged out')).to_stdout
    end
  end

  describe '#info' do
    let(:auth) { Luciq::Commands::Auth.new }

    it 'displays CLI configuration' do
      expect { auth.info }.to output(include('Luciq CLI version', 'URL:', 'Authentication Token:')).to_stdout
    end

    context 'when token is not set' do
      before { ENV['LUCIQ_AUTH_TOKEN'] = '' }

      it 'shows (not set) for token' do
        expect { auth.info }.to output(include('(not set)')).to_stdout
      end
    end
  end
end
