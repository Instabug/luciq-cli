# frozen_string_literal: true

require 'thor'
require 'luciq/version'
require 'luciq/commands/auth'
require 'luciq/commands/upload'

module Luciq
  class UploadCLI < Thor
    desc 'android-mapping FILE', 'Upload Android mapping file'
    long_desc <<~DESC
      Upload Android mapping files to Luciq for crash symbolication.
      File format: .zip containing a single text file
      Example:
        luciq upload android-mapping mapping.zip --app-token APP_TOKEN --version-name 1.0.0 --version-code 1
    DESC
    option :app_token, type: :string, required: true, desc: 'Your Luciq application token'
    option :version_name, type: :string, required: true, desc: 'App version name (e.g., 1.0.0)'
    option :version_code, type: :string, required: true, desc: 'App version code (e.g., 1)'
    def android_mapping(file)
      Commands::Upload.new(options).android_mapping(file)
    end

    desc 'react-native-sourcemap FILE', 'Upload React Native sourcemap file'
    long_desc <<~DESC
      Upload React Native sourcemap files to Instabug for crash symbolication.
      File format: .json sourcemap file (e.g., index.android.bundle.map)
      Example:
        luciq upload react-native-sourcemap index.android.bundle.map --app-token APP_TOKEN --os android --version-name 1.0.0 --version-code 1
    DESC
    option :app_token, type: :string, required: true, desc: 'Your application token'
    option :os, type: :string, enum: %w[ios android], desc: 'Target OS (ios or android)'
    option :version_name, type: :string, desc: 'App version name (e.g., 1.0.0)'
    option :version_code, type: :string, desc: 'App version code (e.g., 1)'
    option :codepush, type: :string, desc: 'CodePush version label (e.g., v42)'
    option :app_variant, type: :string, desc: 'App variant (e.g., prod, staging)'
    def react_native_sourcemap(file)
      Commands::Upload.new(options).react_native_sourcemap(file)
    end
  end

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
