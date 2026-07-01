# frozen_string_literal: true

require 'net/http'
require 'net/http/post/multipart'
require 'json'
require 'uri'
require 'luciq/config'

module Luciq
  module API
    class Client
      SYMBOLS_FILES_PATH = '/api/sdk/v3/symbols_files'
      SO_FILES_PATH = '/api/web/public/so_files'
      FLUTTER_IOS_SYMBOLS_PATH = '/api/web/public/flutter-symbol-files/ios'
      FLUTTER_ANDROID_SYMBOLS_PATH = '/api/web/public/flutter-symbol-files/android'

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

      def upload_ios_dsym(file_path:, app_token:)
        upload_dsym(file_path: file_path, app_token: app_token)
      end

      def upload_android_mapping(file_path:, app_token:, version_code:, version_name:)
        upload_mapping(
          file_path: file_path, app_token: app_token,
          version_code: version_code, version_name: version_name
        )
      end

      def upload_android_ndk(file_path:, app_token:, app_version:, arch:)
        upload_so_file(file_path: file_path, app_token: app_token, app_version: app_version, arch: arch)
      end

      def upload_react_native_ios_dsym(file_path:, app_token:)
        upload_dsym(file_path: file_path, app_token: app_token)
      end

      def upload_react_native_ios_sourcemap(file_path:, app_token:, app_version:)
        upload_react_native_sourcemap(
          file_path: file_path, app_token: app_token, os: 'ios', app_version: app_version
        )
      end

      def upload_react_native_android_mapping(file_path:, app_token:, version_code:, version_name:)
        upload_mapping(
          file_path: file_path, app_token: app_token,
          version_code: version_code, version_name: version_name
        )
      end

      def upload_react_native_android_sourcemap(file_path:, app_token:, app_version:)
        upload_react_native_sourcemap(
          file_path: file_path, app_token: app_token, os: 'android', app_version: app_version
        )
      end

      def upload_react_native_ndk(file_path:, app_token:, app_version:, arch:)
        upload_so_file(file_path: file_path, app_token: app_token, app_version: app_version, arch: arch)
      end

      def upload_flutter_ios_dsym(file_path:, app_token:)
        upload_dsym(file_path: file_path, app_token: app_token)
      end

      def upload_flutter_ios_sourcemap(file_path:, app_token:, version_name:, version_code:)
        upload_flutter_symbols(
          FLUTTER_IOS_SYMBOLS_PATH,
          file_path: file_path, app_token: app_token,
          version_name: version_name, version_code: version_code
        )
      end

      def upload_flutter_android_mapping(file_path:, app_token:, version_code:, version_name:)
        upload_mapping(
          file_path: file_path, app_token: app_token,
          version_code: version_code, version_name: version_name
        )
      end

      def upload_flutter_android_sourcemap(file_path:, app_token:, version_name:, version_code:)
        upload_flutter_symbols(
          FLUTTER_ANDROID_SYMBOLS_PATH,
          file_path: file_path, app_token: app_token,
          version_name: version_name, version_code: version_code
        )
      end

      def upload_flutter_ndk(file_path:, app_token:, app_version:, arch:)
        upload_so_file(file_path: file_path, app_token: app_token, app_version: app_version, arch: arch)
      end

      private

      def upload_dsym(file_path:, app_token:)
        uri = build_uri(SYMBOLS_FILES_PATH)
        File.open(file_path, 'rb') do |file|
          params = {
            'symbols_file' => UploadIO.new(file, 'application/octet-stream', File.basename(file_path)),
            'application_token' => app_token,
            'os' => 'ios'
          }
          post_multipart(uri, params)
        end
      end

      def upload_mapping(file_path:, app_token:, version_code:, version_name:)
        uri = build_uri(SYMBOLS_FILES_PATH)
        File.open(file_path, 'rb') do |file|
          params = {
            'symbols_file' => UploadIO.new(file, 'application/octet-stream', File.basename(file_path)),
            'application_token' => app_token,
            'os' => 'android',
            'app_version' => { code: version_code, name: version_name }.to_json
          }
          post_multipart(uri, params)
        end
      end

      def upload_react_native_sourcemap(file_path:, app_token:, os:, app_version:)
        uri = build_uri(SYMBOLS_FILES_PATH)
        File.open(file_path, 'rb') do |file|
          params = {
            'symbols_file' => UploadIO.new(file, source_map_content_type(file_path), File.basename(file_path)),
            'application_token' => app_token,
            'platform' => 'react_native',
            'os' => os,
            'app_version' => app_version.to_json
          }
          post_multipart(uri, params)
        end
      end

      def upload_so_file(file_path:, app_token:, app_version:, arch:)
        uri = build_uri(SO_FILES_PATH)
        File.open(file_path, 'rb') do |file|
          params = {
            'so_file' => UploadIO.new(file, 'application/octet-stream', File.basename(file_path)),
            'application_token' => app_token,
            'app_version' => app_version,
            'arch' => arch
          }
          post_multipart(uri, params)
        end
      end

      def upload_flutter_symbols(path, file_path:, app_token:, version_name:, version_code:)
        uri = build_uri(path)
        File.open(file_path, 'rb') do |file|
          params = {
            'file' => UploadIO.new(file, 'application/octet-stream', File.basename(file_path)),
            'application_token' => app_token,
            'app_version_name' => version_name,
            'app_version_code' => version_code
          }
          post_multipart(uri, params)
        end
      end

      def post_multipart(uri, params)
        request = Net::HTTP::Post::Multipart.new(uri.path, params)
        apply_headers(request)
        execute(uri, request)
      end

      def source_map_content_type(file_path)
        file_path.downcase.end_with?('.json') ? 'application/json' : 'text/plain'
      end

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
