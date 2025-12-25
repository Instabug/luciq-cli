# frozen_string_literal: true

require 'net/http'
require 'net/http/post/multipart'
require 'json'
require 'uri'
require 'luciq/config'

module Luciq
  module API
    class Client
      def initialize
        @token = Config.load_token
        @base_url = Config.load_base_url
      end

      def whoami
        uri = build_uri('/api/web/public/cli/whoami')
        request = Net::HTTP::Get.new(uri)
        apply_headers(request)
        execute(uri, request)
      end

      def upload_android_mapping(file_path:, app_token:, version_code:, version_name:)
        uri = build_uri('/api/web/public/mappings')

        File.open(file_path, 'rb') do |file|
          params = {
            'mapping_file' => UploadIO.new(file, 'application/octet-stream', File.basename(file_path)),
            'application_token' => app_token,
            'app_version_code' => version_code,
            'app_version_name' => version_name
          }

          request = Net::HTTP::Post::Multipart.new(uri.path, params)
          apply_headers(request)
          execute(uri, request)
        end
      end

      def upload_react_native_sourcemap(file_path:, app_token:, os: nil, app_version: nil)
        uri = build_uri('/api/sdk/v3/symbols_files')

        File.open(file_path, 'rb') do |file|
          params = {
            'symbols_file' => UploadIO.new(file, 'application/octet-stream', File.basename(file_path)),
            'application_token' => app_token,
            'platform' => 'react_native'
          }

          params['os'] = os if os
          params['app_version'] = app_version.to_json if app_version

          request = Net::HTTP::Post::Multipart.new(uri.path, params)
          apply_headers(request)
          execute(uri, request)
        end
      end

      private

      def build_uri(path)
        URI("#{@base_url}#{path}")
      end

      def apply_headers(request)
        request['User-Agent'] = "luciq-cli/#{Luciq::VERSION}"
        request['Authorization'] = @token
      end

      def execute(uri, request)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.open_timeout = 30
        http.read_timeout = 300

        response = http.request(request)
        return JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)

        raise "Request failed (#{response.code}): #{response.body}"
      end
    end
  end
end
