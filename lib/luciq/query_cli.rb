# frozen_string_literal: true

require 'thor'
require 'luciq/commands/query'

module Luciq
  # Shared Thor option groups for query commands.
  module QueryOptions
    MODES = %w[beta production staging alpha qa development].freeze

    def self.app(thor)
      thor.option :slug, type: :string, required: true, desc: 'Application slug'
      thor.option :mode, type: :string, required: true, enum: MODES, desc: 'Application mode'
    end

    def self.page(thor)
      thor.option :offset, type: :numeric, desc: 'Number of results to skip'
      thor.option :limit, type: :numeric, desc: 'Maximum number of results to return'
    end

    def self.sort(thor)
      thor.option :sort_by, type: :string, desc: 'Sort field'
      thor.option :direction, type: :string, enum: %w[asc desc], desc: 'Sort direction'
    end

    def self.raw_filters(thor)
      thor.option :filters, type: :string, desc: 'Raw filter JSON, merged into the request'
    end
  end

  class CrashesCLI < Thor
    desc 'list', 'List crashes for an application'
    long_desc(<<~DESC, wrap: false)
      List crashes for an application.

      Common filters have dedicated flags: --status, --platform, --type, --app-version.
      Pass any other supported filter as a JSON object via --filters:
        date_ms        {"gte": <ms>, "lte": <ms>}  occurrence time range
        status_id      [1,2,3]  (1=open 2=closed 3=in_progress)
        teams          ["<team-id>", ...]
        app_versions   ["1.2.3", ...]
        devices        ["iPhone15,2", ...]
        os_versions    ["17.4", ...]
        platform       ["IOS","ANDROID","DART","JAVASCRIPT"]
        current_views  ["<screen-name>", ...]
        type           ["CRASH","ANR","OOM","NON_FATAL"]
        subtype        ["CRITICAL","ERROR","WARNING","INFO"]  (needs NON_FATAL in type)
        feature_flags  ["<flag>" or "<flag> -> <variant>", ...]

      Example: --filters '{"devices":["iPhone15,2"],"type":["NON_FATAL"]}'
    DESC
    QueryOptions.app(self)
    QueryOptions.page(self)
    QueryOptions.sort(self)
    option :status, type: :array, enum: %w[open closed in_progress], desc: 'Filter by status'
    option :platform, type: :array, enum: %w[IOS ANDROID DART JAVASCRIPT], desc: 'Filter by platform'
    option :type, type: :array, enum: %w[CRASH ANR OOM NON_FATAL], desc: 'Filter by crash type'
    option :app_version, type: :array, desc: 'Filter by app version(s)'
    QueryOptions.raw_filters(self)
    def list
      Commands::Query.new(options).crashes_list
    end

    desc 'show', 'Show details for a single crash'
    QueryOptions.app(self)
    option :number, type: :numeric, required: true, desc: 'Crash number'
    def show
      Commands::Query.new(options).crash_show(options[:number])
    end

    desc 'patterns', 'Show crash patterns for a single crash'
    long_desc(<<~DESC, wrap: false)
      Show crash patterns (grouped dimensions) for a single crash.

      Typed flags: --pattern-key, --sort-by, --direction. Other filters via --filters:
        date_ms       {"gte": <ms>, "lte": <ms>}
        app_versions  ["1.2.3", ...]
        devices       ["iPhone15,2", ...]
        os_versions   ["17.4", ...]
    DESC
    QueryOptions.app(self)
    option :number, type: :numeric, required: true, desc: 'Crash number'
    option :pattern_key, type: :string,
                         enum: %w[app_versions devices oses current_views app_status experiments],
                         desc: 'Pattern dimension'
    option :sort_by, type: :string, enum: %w[occurrences_count last_seen first_seen], desc: 'Sort field'
    option :direction, type: :string, enum: %w[asc desc], desc: 'Sort direction'
    QueryOptions.raw_filters(self)
    def patterns
      Commands::Query.new(options).crash_patterns(options[:number])
    end

    desc 'diagnostics', 'Show diagnostics for a single crash'
    QueryOptions.app(self)
    option :number, type: :numeric, required: true, desc: 'Crash number'
    def diagnostics
      Commands::Query.new(options).crash_diagnostics(options[:number])
    end

    desc 'hangs', 'List app hangs for an application'
    long_desc(<<~DESC, wrap: false)
      List app hangs for an application.

      Typed flags: --status, --platform, --app-version. Other filters via --filters:
        date_ms        {"gte": <ms>, "lte": <ms>}
        status_id      [1,2,3]
        teams          ["<team-id>", ...]
        app_versions   ["1.2.3", ...]
        devices        ["iPhone15,2", ...]
        os_versions    ["17.4", ...]
        platform       ["IOS","ANDROID","DART","JAVASCRIPT"]
        current_views  ["<screen-name>", ...]
    DESC
    QueryOptions.app(self)
    QueryOptions.page(self)
    QueryOptions.sort(self)
    option :status, type: :array, enum: %w[open closed in_progress], desc: 'Filter by status'
    option :platform, type: :array, enum: %w[IOS ANDROID DART JAVASCRIPT], desc: 'Filter by platform'
    option :app_version, type: :array, desc: 'Filter by app version(s)'
    QueryOptions.raw_filters(self)
    def hangs
      Commands::Query.new(options).app_hangs
    end

    desc 'occurrence-tokens', 'List occurrence tokens for a crash'
    long_desc(<<~DESC, wrap: false)
      List occurrence tokens for a crash (paginate with --current-token / --direction).

      Filters via --filters:
        date_ms        {"gte": <ms>, "lte": <ms>}
        app_versions   ["1.2.3", ...]
        app_status     ["foreground","background"]
        devices        ["iPhone15,2", ...]
        os_versions    ["17.4", ...]
        experiments    ["<experiment>", ...]
        current_views  ["<screen-name>", ...]
    DESC
    QueryOptions.app(self)
    option :number, type: :numeric, required: true, desc: 'Crash number'
    option :current_token, type: :string, desc: 'Pagination cursor token'
    option :direction, type: :string, enum: %w[first last], desc: 'Pagination direction'
    QueryOptions.raw_filters(self)
    def occurrence_tokens
      Commands::Query.new(options).occurrence_tokens(options[:number])
    end

    desc 'occurrence', 'Show details for a single crash occurrence'
    QueryOptions.app(self)
    option :number, type: :numeric, required: true, desc: 'Crash number'
    option :ulid, type: :string, required: true, desc: 'State/occurrence ULID token'
    def occurrence
      Commands::Query.new(options).occurrence_details(options[:number], options[:ulid])
    end
  end

  class BugsCLI < Thor
    desc 'list', 'List bugs for an application'
    long_desc(<<~DESC, wrap: false)
      List bugs for an application.

      All current filters have typed flags: --status (new/closed/in_progress),
      --priority (na/trivial/minor/major/blocker), --app-version. The raw --filters
      object accepts the same keys:
        status_id    [1,2,3]  (1=New 2=Closed 3=In Progress)
        priority_id  [-1,1,2,3,4]  (-1=N/A 1=Trivial 2=Minor 3=Major 4=Blocker)
        app_version  ["1.2.3", ...]
    DESC
    QueryOptions.app(self)
    QueryOptions.page(self)
    QueryOptions.sort(self)
    option :status, type: :array, enum: %w[new closed in_progress], desc: 'Filter by status'
    option :priority, type: :array, enum: %w[na trivial minor major blocker], desc: 'Filter by priority'
    option :app_version, type: :array, desc: 'Filter by app version(s)'
    QueryOptions.raw_filters(self)
    def list
      Commands::Query.new(options).bugs_list
    end

    desc 'show', 'Show details for a single bug'
    QueryOptions.app(self)
    option :number, type: :numeric, required: true, desc: 'Bug number'
    def show
      Commands::Query.new(options).bug_show(options[:number])
    end

    desc 'update', 'Update a bug (status, priority, tags, or mark duplicate)'
    QueryOptions.app(self)
    option :number, type: :numeric, required: true, desc: 'Bug number'
    option :status, type: :string, enum: %w[new closed in_progress], desc: 'New status'
    option :priority, type: :string, enum: %w[na trivial minor major blocker], desc: 'New priority'
    option :tags, type: :array, desc: 'Tags to set'
    option :duplicate_of, type: :numeric, desc: 'Bug number this is a duplicate of'
    def update
      Commands::Query.new(options).bug_update(options[:number])
    end
  end

  class ApmCLI < Thor
    METRICS = %w[network launch flows screen_loading frame_drop].freeze

    desc 'groups', 'Rank APM groups worst-first for an application'
    long_desc(<<~DESC, wrap: false)
      Rank APM groups worst-first. --metric is required (network, launch, flows,
      screen_loading, frame_drop).

      --sort is a JSON object: {"by": <field>, "direction": "asc"|"desc"}
        by: failure_rate, p95, p50, apdex, apdex_change, occurrences, dissat_count

      --filters is a JSON object. Common keys: date_ms {"gte","lte"},
      app_version ["1.2.3"], platform ["ios","android"], group_name, key_metric,
      count, dissat_count, apdex, apdex_change, teams. Available filters vary by
      --metric; see the Luciq API docs for the full per-metric set.
    DESC
    QueryOptions.app(self)
    option :metric, type: :string, required: true, enum: METRICS, desc: 'APM metric'
    QueryOptions.page(self)
    option :sort, type: :string, desc: 'Sort JSON object ({ "by": ..., "direction": ... })'
    QueryOptions.raw_filters(self)
    def groups
      Commands::Query.new(options).apm_groups
    end

    desc 'group', 'Fetch APM panels for a single group'
    long_desc(<<~DESC, wrap: false)
      Fetch APM panels (charts/tables/summary) for a single group. --metric is
      required; identify the group with --group-uuid or --group-url. --method
      applies to the network metric.

      --views is a JSON array selecting which panels/tables to return.
      --filters is a JSON object; keys vary by metric and include date_ms,
      app_version, platform ["ios","android"], device, os_version, country,
      carrier, radio, failure_name, failure_type, response_time_ms,
      custom_attributes, experiment. See the Luciq API docs for the full schema.
    DESC
    QueryOptions.app(self)
    option :metric, type: :string, required: true, enum: METRICS, desc: 'APM metric'
    option :group_uuid, type: :string, desc: 'Group UUID (or use --group-url)'
    option :group_url, type: :string, desc: 'Group URL (or use --group-uuid)'
    option :method, type: :string, enum: %w[GET POST PUT PATCH DELETE HEAD OPTIONS], desc: 'HTTP method (network)'
    option :views, type: :string, desc: 'Views JSON array'
    QueryOptions.raw_filters(self)
    def group
      Commands::Query.new(options).apm_group
    end

    desc 'occurrence', 'Inspect APM occurrences in a group'
    long_desc(<<~DESC, wrap: false)
      Inspect APM occurrences in a group. --metric and --selector
      (worst/by_token/list) are required; identify the group with --group-uuid or
      --group-url. For by_token pass --token; for list paginate with
      --current-token / --direction / --limit.

      --filters is a JSON object; keys vary by metric and include date_ms,
      app_version, platform ["ios","android"], device, os_version, country,
      carrier, radio, failure_name, failure_type, response_time_ms,
      latency_percentile, experiment. See the Luciq API docs for the full schema.
    DESC
    QueryOptions.app(self)
    option :metric, type: :string, required: true, enum: METRICS, desc: 'APM metric'
    option :selector, type: :string, required: true, enum: %w[worst by_token list], desc: 'Occurrence selector'
    option :group_uuid, type: :string, desc: 'Group UUID (or use --group-url)'
    option :group_url, type: :string, desc: 'Group URL (or use --group-uuid)'
    option :method, type: :string, enum: %w[GET POST PUT PATCH DELETE HEAD OPTIONS], desc: 'HTTP method (network)'
    option :token, type: :string, desc: 'Occurrence token (for by_token)'
    option :current_token, type: :string, desc: 'Pagination cursor token (for list)'
    option :direction, type: :string, enum: %w[first last], desc: 'Pagination direction (for list)'
    option :limit, type: :numeric, desc: 'Maximum number of occurrences (for list)'
    QueryOptions.raw_filters(self)
    def occurrence
      Commands::Query.new(options).apm_occurrence
    end
  end

  class ReviewsCLI < Thor
    desc 'list', 'List reviews for an application'
    long_desc(<<~DESC, wrap: false)
      List reviews for an application.

      Typed flags: --rating (1-5), --country, --os (ios/android), --sort-by (date),
      --sort-direction. Other filters via --filters:
        date_ms      {"gte": <ms>, "lte": <ms>}
        app_version  ["1.2.3", ...]
        prompt_type  ["custom","native","app_store"]
    DESC
    QueryOptions.app(self)
    QueryOptions.page(self)
    option :sort_by, type: :string, enum: %w[date], desc: 'Sort field'
    option :sort_direction, type: :string, enum: %w[asc desc], desc: 'Sort direction'
    option :rating, type: :array, desc: 'Filter by rating(s) 1-5'
    option :country, type: :string, desc: 'Filter by country'
    option :os, type: :array, enum: %w[ios android], desc: 'Filter by OS'
    QueryOptions.raw_filters(self)
    def list
      Commands::Query.new(options).reviews_list
    end
  end

  class SurveysCLI < Thor
    desc 'list', 'List surveys for an application'
    long_desc(<<~DESC, wrap: false)
      List surveys for an application.

      Typed flags --type and --status both accept 0, 1, or 2. The raw --filters
      object accepts the same keys: {"type": [0,1,2], "status": [0,1,2]}.
    DESC
    QueryOptions.app(self)
    QueryOptions.page(self)
    option :type, type: :array, desc: 'Filter by type (0, 1, 2)'
    option :status, type: :array, desc: 'Filter by status (0, 1, 2)'
    QueryOptions.raw_filters(self)
    def list
      Commands::Query.new(options).surveys_list
    end

    desc 'show', 'Show a survey\'s details and response statistics'
    long_desc(<<~DESC, wrap: false)
      Show a survey's questions and response statistics. Paginate responses with --page.

      Filters via --filters:
        date_ms          {"gte": <ms>, "lte": <ms>}
        search_words     "<free text>"
        response_status  [0,1]
        nps              <0-10>
        locale           "<locale>"
        app_versions     ["1.2.3", ...]
        devices          ["iPhone15,2", ...]
        os_versions      ["17.4", ...]
        countries        ["US", ...]
        platforms        ["ios","android"]
    DESC
    QueryOptions.app(self)
    option :id, type: :numeric, required: true, desc: 'Survey id'
    option :page, type: :numeric, desc: 'Responses page number'
    QueryOptions.raw_filters(self)
    def show
      Commands::Query.new(options).survey_show(options[:id])
    end
  end

  class AppsCLI < Thor
    desc 'list', 'List applications accessible to the authenticated developer'
    QueryOptions.page(self)
    option :platform, type: :string, enum: %w[ios android react_native flutter], desc: 'Filter by platform'
    def list
      Commands::Query.new(options).apps_list
    end
  end
end
