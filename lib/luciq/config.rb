# frozen_string_literal: true

module Luciq
  class Config
    CONFIG_FILE = File.expand_path('~/.luciqrc')
    DEFAULT_BASE_URL = 'https://api.luciq.ai'

    class << self
      def load_base_url
        ENV['LUCIQ_URL'] || load_value('url') || DEFAULT_BASE_URL
      end

      def load_token
        ENV['LUCIQ_AUTH_TOKEN'] || load_value('token')
      end

      def save_token(token)
        add_value('token', token)
      end

      def clear_token
        delete_value('token')
      end

      private

      def load_value(key)
        return nil unless File.exist?(CONFIG_FILE)

        File.readlines(CONFIG_FILE).each do |line|
          line = line.strip
          next if line.empty? || line.start_with?('#')

          if line.include?('=')
            k, v = line.split('=', 2)
            return v if k == key
          end
        end

        nil
      end

      def add_value(key, value)
        lines = File.exist?(CONFIG_FILE) ? File.readlines(CONFIG_FILE) : []
        key_found = false
        result = []

        # Modify the existing value if it exists
        lines.each do |line|
          if line.strip.start_with?("#{key}=")
            result << "#{key}=#{value}\n"
            key_found = true
          else
            result << line
          end
        end

        result << "#{key}=#{value}\n" unless key_found

        File.write(CONFIG_FILE, result.join)
      end

      def delete_value(key)
        return unless File.exist?(CONFIG_FILE)

        lines = File.readlines(CONFIG_FILE)
        result = lines.reject { |line| line.strip.start_with?("#{key}=") }

        File.write(CONFIG_FILE, result.join)
      end
    end
  end
end
