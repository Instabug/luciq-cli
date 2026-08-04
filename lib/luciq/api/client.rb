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
        uri = build_uri('/api/cli/whoami')
        request = Net::HTTP::Get.new(uri)
        apply_headers(request)
        execute(uri, request)
      end

      # Invokes a query tool by name with a hash of arguments (slug, mode,
      # filters, pagination, ...) sent as a JSON body.
      def invoke_tool(tool_name, arguments = {})
        uri = build_uri("/api/cli/tools/#{tool_name}")
        request = Net::HTTP::Post.new(uri)
        request['Content-Type'] = 'application/json'
        request.body = arguments.to_json
        apply_headers(request)
        execute(uri, request)
      end

      def upload(command, file_path, fields = {})
        uri = build_uri("/api/cli/uploads/#{command}")
        File.open(file_path, 'rb') do |file|
          params = {
            'file' => UploadIO.new(file, content_type_for(file_path), File.basename(file_path))
          }.merge(fields)
          post_multipart(uri, params)
        end
      end

      private

      def post_multipart(uri, params)
        request = Net::HTTP::Post::Multipart.new(uri.path, params)
        apply_headers(request)
        execute(uri, request)
      end

      def content_type_for(file_path)
        case File.extname(file_path).downcase
        when '.json' then 'application/json'
        when '.txt' then 'text/plain'
        else 'application/octet-stream'
        end
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
        raise "Request failed (#{response.code}): #{response.body}" unless response.is_a?(Net::HTTPSuccess)

        JSON.parse(response.body)
      rescue JSON::ParserError
        response.body
      end
    end
  end
end
