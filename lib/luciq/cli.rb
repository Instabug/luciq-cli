# frozen_string_literal: true

require 'thor'
require 'luciq/version'
require 'luciq/commands/auth'
require 'luciq/upload_cli'

module Luciq
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc 'login', 'Authenticate with Luciq'
    long_desc <<~DESC
      Authenticate with Luciq using a CLI token.
      Generate a CLI token from your Luciq dashboard: https://dashboard.luciq.ai/company/cli
      The token will be saved in ~/.luciqrc
    DESC
    option :auth_token, type: :string, desc: 'CLI authentication token'
    def login
      Commands::Auth.new(options).login
    end

    desc 'logout', 'Remove saved authentication'
    def logout
      Commands::Auth.new(options).logout
    end

    desc 'whoami', 'Show current authenticated user'
    def whoami
      Commands::Auth.new(options).whoami
    end

    desc 'info', 'Show CLI configuration'
    def info
      Commands::Auth.new(options).info
    end

    desc 'upload SUBCOMMAND', 'Upload symbol files to Luciq'
    subcommand 'upload', UploadCLI

    desc 'version', 'Show CLI version'
    def version
      puts "luciq-cli #{Luciq::VERSION}"
    end

    map %w[--version] => :version
  end
end
