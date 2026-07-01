# frozen_string_literal: true

require 'thor'
require 'luciq/commands/upload'

module Luciq
  class UploadCLI < Thor
    ARCHITECTURES = Commands::Upload::ALLOWED_ARCHITECTURES

    desc 'ios-dsym FILE', 'Upload iOS dSYM file'
    long_desc <<~DESC
      Upload iOS dSYM files to Luciq for crash symbolication.
      File format: .zip containing dSYM files
      Example:
        luciq upload ios-dsym MyApp.dSYM.zip --app-token APP_TOKEN
    DESC
    option :app_token, type: :string, required: true, desc: 'Your Luciq application token'
    def ios_dsym(file)
      Commands::Upload.new(options).ios_dsym(file)
    end

    desc 'android-mapping FILE', 'Upload Android mapping file'
    long_desc <<~DESC
      Upload Android Proguard/R8 mapping files to Luciq for crash deobfuscation.
      File format: mapping.txt
      Example:
        luciq upload android-mapping mapping.txt --app-token APP_TOKEN --version-name 1.0.0 --version-code 1
    DESC
    option :app_token, type: :string, required: true, desc: 'Your Luciq application token'
    option :version_name, type: :string, required: true, desc: 'App version name (e.g., 1.0.0)'
    option :version_code, type: :string, required: true, desc: 'App version code (e.g., 1)'
    def android_mapping(file)
      Commands::Upload.new(options).android_mapping(file)
    end

    desc 'android-ndk FILE', 'Upload Android NDK .so files'
    long_desc <<~DESC
      Upload Android NDK shared object (.so) files to Luciq for native crash symbolication.
      File format: .zip containing the .so files
      Example:
        luciq upload android-ndk so-files.zip --app-token APP_TOKEN --version-name 1.0.0 --arch arm64-v8a
    DESC
    option :app_token, type: :string, required: true, desc: 'Your Luciq application token'
    option :version_name, type: :string, required: true, desc: 'App version name (e.g., 1.0.0)'
    option :arch, type: :string, required: true, enum: ARCHITECTURES, desc: 'CPU architecture'
    def android_ndk(file)
      Commands::Upload.new(options).android_ndk(file)
    end

    desc 'react-native-ios-dsym FILE', 'Upload React Native iOS dSYM file'
    long_desc <<~DESC
      Upload React Native iOS dSYM files to Luciq for native crash symbolication.
      File format: .zip containing dSYM files
      Example:
        luciq upload react-native-ios-dsym dsyms.zip --app-token APP_TOKEN
    DESC
    option :app_token, type: :string, required: true, desc: 'Your application token'
    def react_native_ios_dsym(file)
      Commands::Upload.new(options).react_native_ios_dsym(file)
    end

    desc 'react-native-ios-sourcemap FILE', 'Upload React Native iOS JavaScript source map'
    long_desc <<~DESC
      Upload React Native iOS JavaScript source maps to Luciq for crash symbolication.
      File format: .json or .txt source map
      Example:
        luciq upload react-native-ios-sourcemap ios-sourcemap.json --app-token APP_TOKEN --version-code 1 --version-name 1.0.0
    DESC
    option :app_token, type: :string, required: true, desc: 'Your application token'
    option :version_code, type: :string, required: true, desc: 'App version code (e.g., 1)'
    option :version_name, type: :string, required: true, desc: 'App version name (e.g., 1.0.0)'
    option :codepush, type: :string, desc: 'CodePush version label (e.g., v42)'
    def react_native_ios_sourcemap(file)
      Commands::Upload.new(options).react_native_ios_sourcemap(file)
    end

    desc 'react-native-android-mapping FILE', 'Upload React Native Android mapping file'
    long_desc <<~DESC
      Upload React Native Android Proguard/R8 mapping files to Luciq for native crash deobfuscation.
      File format: mapping.txt
      Example:
        luciq upload react-native-android-mapping mapping.txt --app-token APP_TOKEN --version-code 1 --version-name 1.0.0
    DESC
    option :app_token, type: :string, required: true, desc: 'Your application token'
    option :version_code, type: :string, required: true, desc: 'App version code (e.g., 1)'
    option :version_name, type: :string, required: true, desc: 'App version name (e.g., 1.0.0)'
    def react_native_android_mapping(file)
      Commands::Upload.new(options).react_native_android_mapping(file)
    end

    desc 'react-native-android-sourcemap FILE', 'Upload React Native Android JavaScript source map'
    long_desc <<~DESC
      Upload React Native Android JavaScript source maps to Luciq for crash deobfuscation.
      File format: .json or .txt source map
      Example:
        luciq upload react-native-android-sourcemap android-sourcemap.json --app-token APP_TOKEN --version-code 1 --version-name 1.0.0
    DESC
    option :app_token, type: :string, required: true, desc: 'Your application token'
    option :version_code, type: :string, required: true, desc: 'App version code (e.g., 1)'
    option :version_name, type: :string, required: true, desc: 'App version name (e.g., 1.0.0)'
    option :codepush, type: :string, desc: 'CodePush version label (e.g., v42)'
    def react_native_android_sourcemap(file)
      Commands::Upload.new(options).react_native_android_sourcemap(file)
    end

    desc 'react-native-ndk FILE', 'Upload React Native NDK .so files'
    long_desc <<~DESC
      Upload React Native NDK shared object (.so) files to Luciq for native crash symbolication.
      File format: .zip containing the .so files
      Example:
        luciq upload react-native-ndk so-files.zip --app-token APP_TOKEN --version-name 1.0.0 --arch arm64-v8a
    DESC
    option :app_token, type: :string, required: true, desc: 'Your application token'
    option :version_name, type: :string, required: true, desc: 'App version name (e.g., 1.0.0)'
    option :arch, type: :string, required: true, enum: ARCHITECTURES, desc: 'CPU architecture'
    def react_native_ndk(file)
      Commands::Upload.new(options).react_native_ndk(file)
    end

    desc 'flutter-ios-dsym FILE', 'Upload Flutter iOS dSYM file'
    long_desc <<~DESC
      Upload Flutter iOS dSYM files to Luciq for native crash symbolication.
      File format: .zip containing dSYM files
      Example:
        luciq upload flutter-ios-dsym MyApp.dSYM.zip --app-token APP_TOKEN
    DESC
    option :app_token, type: :string, required: true, desc: 'Your Luciq application token'
    def flutter_ios_dsym(file)
      Commands::Upload.new(options).flutter_ios_dsym(file)
    end

    desc 'flutter-ios-sourcemap FILE', 'Upload Flutter iOS Dart sourcemap file'
    long_desc <<~DESC
      Upload Flutter iOS Dart sourcemap files to Luciq for crash symbolication.
      File format: .zip containing Flutter debug symbols
      Example:
        luciq upload flutter-ios-sourcemap app.ios-arm64.symbols.zip --app-token APP_TOKEN --version-name 1.0.0 --version-code 1
    DESC
    option :app_token, type: :string, required: true, desc: 'Your Luciq application token'
    option :version_name, type: :string, required: true, desc: 'App version name (e.g., 1.0.0)'
    option :version_code, type: :string, required: true, desc: 'App version code (e.g., 1)'
    def flutter_ios_sourcemap(file)
      Commands::Upload.new(options).flutter_ios_sourcemap(file)
    end

    desc 'flutter-android-mapping FILE', 'Upload Flutter Android mapping file'
    long_desc <<~DESC
      Upload Flutter Android Proguard/R8 mapping files to Luciq for native crash deobfuscation.
      File format: mapping.txt
      Example:
        luciq upload flutter-android-mapping mapping.txt --app-token APP_TOKEN --version-code 1 --version-name 1.0.0
    DESC
    option :app_token, type: :string, required: true, desc: 'Your Luciq application token'
    option :version_code, type: :string, required: true, desc: 'App version code (e.g., 1)'
    option :version_name, type: :string, required: true, desc: 'App version name (e.g., 1.0.0)'
    def flutter_android_mapping(file)
      Commands::Upload.new(options).flutter_android_mapping(file)
    end

    desc 'flutter-android-sourcemap FILE', 'Upload Flutter Android Dart sourcemap file'
    long_desc <<~DESC
      Upload Flutter Android Dart sourcemap files to Luciq for crash symbolication.
      File format: .zip containing Flutter debug symbols
      Example:
        luciq upload flutter-android-sourcemap app.android-arm64.symbols.zip --app-token APP_TOKEN --version-name 1.0.0 --version-code 1
    DESC
    option :app_token, type: :string, required: true, desc: 'Your Luciq application token'
    option :version_name, type: :string, required: true, desc: 'App version name (e.g., 1.0.0)'
    option :version_code, type: :string, required: true, desc: 'App version code (e.g., 1)'
    def flutter_android_sourcemap(file)
      Commands::Upload.new(options).flutter_android_sourcemap(file)
    end

    desc 'flutter-ndk FILE', 'Upload Flutter NDK .so files'
    long_desc <<~DESC
      Upload Flutter NDK shared object (.so) files to Luciq for native crash symbolication.
      File format: .zip containing the .so files
      Example:
        luciq upload flutter-ndk so-files.zip --app-token APP_TOKEN --version-name 1.0.0 --arch arm64-v8a
    DESC
    option :app_token, type: :string, required: true, desc: 'Your Luciq application token'
    option :version_name, type: :string, required: true, desc: 'App version name (e.g., 1.0.0)'
    option :arch, type: :string, required: true, enum: ARCHITECTURES, desc: 'CPU architecture'
    def flutter_ndk(file)
      Commands::Upload.new(options).flutter_ndk(file)
    end
  end
end
