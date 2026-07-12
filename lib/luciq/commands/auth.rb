# frozen_string_literal: true

require 'luciq/api/client'
require 'luciq/config'

module Luciq
  module Commands
    class Auth
      def initialize(options = {})
        @options = options
      end

      def login
        token = @options[:auth_token]

        unless token
          puts 'Login to Luciq'
          puts '=' * 40
          puts 'Generate a CLI token from your Luciq dashboard: https://dashboard.luciq.ai/company/luciq-cli'
          puts
          puts "Note: For self-hosted clusters, replace 'dashboard' with your cluster name."
          puts
          print 'Paste your CLI token: '
          token = $stdin.gets.chomp
          puts
        end

        if token.empty?
          puts '✗ No token provided.'
          exit 1
        end

        Config.save_token(token)

        puts '✓ Token saved to ~/.luciqrc'
        puts "Run 'luciq info' to verify your configuration."
      end

      def whoami
        client = API::Client.new

        unless Config.load_token
          puts '✗ Not authenticated. Run: luciq login'
          exit 1
        end

        response = client.whoami

        puts 'Authenticated as:'
        puts "  Email: #{response['email']}"
        puts "  Name:  #{response['name']}"
      rescue StandardError => e
        puts "✗ #{e.message}"
        exit 1
      end

      def logout
        Config.clear_token
        puts '✓ Logged out.'
      end

      def info
        puts "Luciq CLI version: #{Luciq::VERSION}"
        puts '=' * 40
        puts
        puts 'Configuration:'
        puts "  URL:                  #{Config.load_base_url}"
        puts "  Authentication Token: #{Config.load_token || '(not set)'}"
      end
    end
  end
end
