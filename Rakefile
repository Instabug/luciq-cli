# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: %i[spec rubocop]

desc 'Sync the Homebrew formula in ../homebrew-tap (or TAP_DIR) with Luciq::VERSION and Gemfile.lock'
task :'formula:bump' do
  require 'digest'
  require 'open-uri'
  require_relative 'lib/luciq/version'

  tap_dir = File.expand_path(ENV.fetch('TAP_DIR', '../homebrew-tap'), __dir__)
  path = File.join(tap_dir, 'Formula', 'luciq-cli.rb')
  unless File.exist?(path)
    raise "#{path} not found — clone https://github.com/luciqai/homebrew-tap next to this repo or set TAP_DIR"
  end

  fetch = lambda do |url|
    URI.parse(url).open(&:read)
  rescue OpenURI::HTTPError => e
    raise "HTTP #{e.io.status.first} fetching #{url} — is the gem published?"
  end

  gemspec = Gem::Specification.load(File.expand_path('luciq-cli.gemspec', __dir__))
  runtime_deps = gemspec.runtime_dependencies.map(&:name).sort

  lock = File.read(File.expand_path('Gemfile.lock', __dir__))
  pins = { 'luciq-cli' => Luciq::VERSION }
  runtime_deps.each do |dep|
    pins[dep] = lock[/^    #{Regexp.escape(dep)} \(([\d.]+)\)/, 1] || raise("#{dep} not found in Gemfile.lock")
  end

  formula = File.read(path)

  missing = runtime_deps.reject { |dep| formula.include?("resource \"#{dep}\" do") }
  raise "formula has no resource block for: #{missing.join(', ')}" if missing.any?

  pins.each do |name, version|
    url = "https://rubygems.org/downloads/#{name}-#{version}.gem"
    sha256 = Digest::SHA256.hexdigest(fetch.call(url))
    pattern = %r{url "https://rubygems\.org/downloads/#{Regexp.escape(name)}-[\d.]+\.gem"\n(\s*)sha256 "\h{64}"}
    replaced = formula.sub!(pattern) { "url \"#{url}\"\n#{Regexp.last_match(1)}sha256 \"#{sha256}\"" }
    raise "url/sha256 pair for #{name} not found in #{path}" unless replaced

    puts "#{name} #{version} #{sha256}"
  end

  File.write(path, formula)
end
