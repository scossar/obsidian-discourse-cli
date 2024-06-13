# frozen_string_literal: true

require 'obsidian'
require_relative '../../category_utils'
require_relative '../../directory_utils'
require_relative '../../discourse_category_fetcher'
require_relative '../../publish_to_discourse'

module Obsidian
  module Commands
    class Sync < Obsidian::Command
      def call(_args, _name)
        selected_dirs = nil
        CLI::UI::Frame.open('Select Directories') do
          dir = DirectoryUtils.vault_dir
          selected_dirs = DirectoryUtils.select_subdirs(dir)
        end

        categories, category_names = nil
        CLI::UI::Frame.open('Fetching Discourse categories') do
          categories, category_names = CategoryUtils.category_loader
        end

        CLI::UI::Frame.open('Sync with Discourse') do
          publisher = PublishToDiscourse.new
          selected_dirs.each do |dir|
            Dir.glob(File.join(dir, '*.md')).each do |file_path|
              puts "syncing file: #{file_path}"
              publisher.publish(file_path, 8)
            end
          end
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
