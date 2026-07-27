# frozen_string_literal: true

require 'luciq/api/client'

module Luciq
  module Commands
    class Upload
      ALLOWED_ARCHITECTURES = %w[armeabi-v7a arm64-v8a x86 x86_64].freeze

      def initialize(options = {})
        @options = options
        @client = API::Client.new
      end

      def ios_dsym(file_path)
        run_upload('ios-dsym', file_path, 'iOS dSYM file', format: :zip)
      end

      def android_mapping(file_path)
        run_upload('android-mapping', file_path, 'Android mapping file')
      end

      def android_ndk(file_path)
        run_upload('android-ndk', file_path, 'Android NDK .so files', format: :zip, arch: true)
      end

      def react_native_ios_dsym(file_path)
        run_upload('react-native-ios-dsym', file_path, 'React Native iOS dSYM', format: :zip)
      end

      def react_native_ios_sourcemap(file_path)
        run_upload('react-native-ios-sourcemap', file_path, 'React Native iOS source map', format: :sourcemap)
      end

      def react_native_android_mapping(file_path)
        run_upload('react-native-android-mapping', file_path, 'React Native Android mapping file')
      end

      def react_native_android_sourcemap(file_path)
        run_upload('react-native-android-sourcemap', file_path, 'React Native Android source map', format: :sourcemap)
      end

      def react_native_ndk(file_path)
        run_upload('react-native-ndk', file_path, 'React Native NDK .so files', format: :zip, arch: true)
      end

      def flutter_ios_dsym(file_path)
        run_upload('flutter-ios-dsym', file_path, 'Flutter iOS dSYM', format: :zip)
      end

      def flutter_ios_sourcemap(file_path)
        run_upload('flutter-ios-sourcemap', file_path, 'Flutter iOS Dart sourcemap', format: :zip)
      end

      def flutter_android_mapping(file_path)
        run_upload('flutter-android-mapping', file_path, 'Flutter Android mapping file')
      end

      def flutter_android_sourcemap(file_path)
        run_upload('flutter-android-sourcemap', file_path, 'Flutter Android Dart sourcemap', format: :zip)
      end

      def flutter_ndk(file_path)
        run_upload('flutter-ndk', file_path, 'Flutter NDK .so files', format: :zip, arch: true)
      end

      private

      def run_upload(command, file_path, label, format: nil, arch: false)
        validate_file!(file_path)
        validate_format!(file_path, format)
        validate_arch! if arch

        puts "Uploading #{label}: #{File.basename(file_path)}"
        puts

        @client.upload(command, file_path, @options)

        puts "✓ #{label} uploaded successfully!"
      rescue StandardError => e
        puts "✗ Upload failed: #{e.message}"
        exit 1
      end

      def validate_file!(file_path)
        unless File.exist?(file_path)
          puts "✗ File not found: #{file_path}"
          exit 1
        end

        return if File.readable?(file_path)

        puts "✗ Cannot read file: #{file_path}"
        exit 1
      end

      def validate_format!(file_path, format)
        case format
        when :zip then validate_zip_extension!(file_path)
        when :sourcemap then validate_sourcemap_extension!(file_path)
        end
      end

      def validate_zip_extension!(file_path)
        return if file_path.downcase.end_with?('.zip')

        puts "✗ File must be a .zip archive: #{file_path}"
        exit 1
      end

      def validate_sourcemap_extension!(file_path)
        return if file_path.downcase.end_with?('.json', '.txt')

        puts "✗ Source map must be a .json or .txt file: #{file_path}"
        exit 1
      end

      def validate_arch!
        return if ALLOWED_ARCHITECTURES.include?(@options[:arch])

        puts "✗ Invalid architecture: #{@options[:arch]}"
        puts "  Allowed values: #{ALLOWED_ARCHITECTURES.join(', ')}"
        exit 1
      end
    end
  end
end
