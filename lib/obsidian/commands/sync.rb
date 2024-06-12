# frozen_string_literal: true

require 'obsidian'
require_relative '../../directory_utils'
require_relative '../../discourse_category_fetcher'

module Obsidian
  module Commands
    class Sync < Obsidian::Command
      def call(_args, _name)
        selected_dirs = []
        discourse_categories = nil
        CLI::UI::Frame.open('Select Directories') do
          dir = DirectoryUtils.vault_dir
          selected_dirs = DirectoryUtils.select_subdirs(dir)
        end

        CLI::UI::Frame.open('Fetching Discourse Categories') do
          @category_fetcher = DiscourseCategoryFetcher.instance
          @categories = @category_fetcher.categories
          @category_names = @category_fetcher.category_names
          puts "category_names: #{@category_names}"
        end
      rescue StandardError => e
        rescue_from_error(e)
      end

      def self.help
        "This will be the help text for #{Obsidian::TOOL_NAME}"
      end

      private

      def rescue_from_error(error)
        CLI::UI::Frame.open('Error') do
          puts "An error occurred: #{error.message}"
          puts "Please check the log file at #{Obsidian::LOG_FILE} for more details"
        end
      end
    end
  end
end
