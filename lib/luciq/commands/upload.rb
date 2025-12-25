# frozen_string_literal: true

require 'luciq/api/client'

module Luciq
  module Commands
    class Upload
      def initialize(options = {})
        @options = options
        @client = API::Client.new
      end

      def android_mapping(file_path)
        validate_file!(file_path)
        validate_zip_extension!(file_path)

        puts "Uploading Android mapping file: #{File.basename(file_path)}"
        puts

        @client.upload_android_mapping(
          file_path: file_path,
          app_token: @options[:app_token],
          version_code: @options[:version_code],
          version_name: @options[:version_name]
        )

        puts '✓ Android mapping file uploaded successfully!'
      rescue StandardError => e
        puts "✗ Upload failed: #{e.message}"
        exit 1
      end

      def react_native_sourcemap(file_path)
        validate_file!(file_path)

        puts "Uploading React Native sourcemap: #{File.basename(file_path)}"
        puts

        app_version = build_app_version

        @client.upload_react_native_sourcemap(
          file_path: file_path,
          app_token: @options[:app_token],
          os: @options[:os],
          app_version: app_version
        )

        puts '✓ React Native sourcemap uploaded successfully!'
      rescue StandardError => e
        puts "✗ Upload failed: #{e.message}"
        exit 1
      end

      private

      def validate_file!(file_path)
        unless File.exist?(file_path)
          puts "✗ File not found: #{file_path}"
          exit 1
        end

        return if File.readable?(file_path)

        puts "✗ Cannot read file: #{file_path}"
        exit 1
      end

      def validate_zip_extension!(file_path)
        return if file_path.downcase.end_with?('.zip')

        puts "✗ File must be a .zip archive: #{file_path}"
        puts '  The ZIP should contain a single text file.'
        exit 1
      end

      def build_app_version
        return nil unless @options[:version_code] || @options[:version_name]

        version = {}
        version[:code] = @options[:version_code] if @options[:version_code]
        version[:name] = @options[:version_name] if @options[:version_name]
        version[:codepush] = @options[:codepush] if @options[:codepush]
        version[:app_variant] = @options[:app_variant] if @options[:app_variant]

        version
      end
    end
  end
end
