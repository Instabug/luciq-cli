# frozen_string_literal: true

require 'json'
require 'luciq/api/client'
require 'luciq/config'
require 'luciq/commands/query_arguments'

module Luciq
  module Commands
    # Read/query commands. Each public method maps one-to-one to an MCP tool:
    # it builds that tool's arguments from typed CLI flags (see QueryArguments)
    # and proxies to the MCP server's CLI endpoint.
    class Query
      include QueryArguments

      def initialize(options = {})
        @options = options
        @client = API::Client.new
      end

      # --- Crashes -----------------------------------------------------------
      def crashes_list
        execute('list_crashes') { base_args.merge(page_args, sort_args, filters_arg(crash_filters)) }
      end

      def crash_show(number)
        execute('crash_details') { base_args.merge(number: number) }
      end

      def crash_patterns(number)
        pattern = { pattern_key: @options[:pattern_key], sort_by: @options[:sort_by],
                    direction: @options[:direction] }.compact
        execute('crash_patterns') do
          base_args.merge(number: number).merge(pattern).merge(filters_arg(raw_filters))
        end
      end

      def crash_diagnostics(number)
        execute('crash_diagnostics') { base_args.merge(number: number) }
      end

      def app_hangs
        execute('list_app_hangs') { base_args.merge(page_args, sort_args, filters_arg(hang_filters)) }
      end

      def occurrence_tokens(number)
        cursor = { current_token: @options[:current_token], direction: @options[:direction] }.compact
        execute('list_occurrences_tokens') do
          base_args.merge(number: number).merge(cursor).merge(filters_arg(raw_filters))
        end
      end

      def occurrence_details(number, ulid)
        execute('get_occurrence_details') { base_args.merge(number: number, ulid: ulid) }
      end

      # --- Bugs --------------------------------------------------------------
      def bugs_list
        execute('list_bugs') { base_args.merge(page_args, sort_args, filters_arg(bug_filters)) }
      end

      def bug_show(number)
        execute('bug_details') { base_args.merge(number: number) }
      end

      def bug_update(number)
        execute('update_bug') { base_args.merge(number: number).merge(bug_update_changes) }
      end

      # --- APM ---------------------------------------------------------------
      def apm_groups
        execute('apm_list_groups') do
          base_args.merge({ metric: @options[:metric] }.compact, page_args)
                   .merge(json_arg(:sort, @options[:sort]), filters_arg(raw_filters))
        end
      end

      def apm_group
        group = { metric: @options[:metric], group_uuid: @options[:group_uuid],
                  group_url: @options[:group_url], method: @options[:method] }.compact
        execute('apm_group_view') do
          base_args.merge(group).merge(json_arg(:views, @options[:views]), filters_arg(raw_filters))
        end
      end

      def apm_occurrence
        selector = { metric: @options[:metric], selector: @options[:selector],
                     group_uuid: @options[:group_uuid], group_url: @options[:group_url],
                     method: @options[:method], token: @options[:token],
                     current_token: @options[:current_token],
                     direction: @options[:direction], limit: @options[:limit] }.compact
        execute('apm_occurrence') { base_args.merge(selector).merge(filters_arg(raw_filters)) }
      end

      # --- Reviews -----------------------------------------------------------
      def reviews_list
        sort = { sort_by: @options[:sort_by], sort_direction: @options[:sort_direction] }.compact
        execute('list_reviews') do
          base_args.merge(page_args, sort).merge(filters_arg(review_filters))
        end
      end

      # --- Surveys -----------------------------------------------------------
      def surveys_list
        execute('list_surveys') { base_args.merge(page_args, filters_arg(survey_filters)) }
      end

      def survey_show(id)
        page = { page: @options[:page] }.compact
        execute('survey_details') { base_args.merge(id: id).merge(page, filters_arg(raw_filters)) }
      end

      # --- Applications & health --------------------------------------------
      def apps_list
        execute('list_applications') do
          { offset: @options[:offset], limit: @options[:limit], platform: @options[:platform] }.compact
        end
      end

      def insights
        execute('app_insights') { base_args.merge(filters_arg(raw_filters)) }
      end

      private

      def execute(tool_name)
        ensure_authenticated!
        print_result(@client.invoke_tool(tool_name, yield))
      rescue StandardError => e
        puts "✗ #{e.message}"
        exit 1
      end

      def ensure_authenticated!
        return if Config.load_token

        puts '✗ Not authenticated. Run: luciq login'
        exit 1
      end

      def print_result(response)
        puts JSON.pretty_generate(response)
      end
    end
  end
end
