# frozen_string_literal: true

require 'obsidian'
require_relative '../../models/directory'
require_relative '../../category_utils'
require_relative '../../directory_utils'
require_relative '../../discourse_category_fetcher'
require_relative '../../errors'
require_relative '../../publish_to_discourse'

module Obsidian
  module Commands
    class Sync < Obsidian::Command
      def call(_args, _name)
        selected_dirs = directory_frames
        category_frames(selected_dirs)
        publishing_frames(selected_dirs)
      rescue Obsidian::Errors::BaseError => e
        rescue_custom_error(e)
      rescue StandardError => e
        rescue_from_error(e)
      end

      def self.help
        "This will be the help text for #{Obsidian::TOOL_NAME}"
      end

      def directory_frames
        CLI::UI::Frame.open('Select Directories') do
          root_dir = DirectoryUtils.vault_dir
          DirectoryUtils.select_subdirs(root_dir)
        end
      end

      def category_frames(selected_dirs)
        categories, category_names = nil
        CLI::UI::Frame.open('Fetching Discourse categories') do
          categories, category_names = CategoryUtils.category_loader
        end
        exit unless categories
        CLI::UI::Frame.open('Select directories for categories') do
          CategoryUtils.directories_for_categories(categories:, category_names:, selected_dirs:)
        end
      end

      def publishing_frames(selected_dirs)
        publisher = PublishToDiscourse.new
        CLI::UI::Frame.open('Publish to Discourse') do
          selected_dirs.each do |dir|
            publish_dir(dir, publisher)
          end
        end
      end

      def publish_dir(dir, _publisher)
        directory = Directory.find_by(path: dir)
        CLI::UI::Frame.open("Publishing notes from {{green:#{dir}}}") do
          Dir.glob(File.join(dir, '*.md')).each do |file_path|
            spin_group = CLI::UI::SpinGroup.new

            spin_group.failure_debrief do |_title, exception|
              puts CLI::UI.fmt "  #{exception}"
            end

            spin_group.add("Note {{green:#{File.basename(file_path)}}}") do
              # publisher.publish(file_path:, directory:)
            end

            spin_group.wait
          end
        end
      end

      private

      def rescue_custom_error(error)
        CLI::UI::Frame.open('Custom Error') do
          puts "An application error occurred: #{error.message}"
        end
      end

      def rescue_from_error(error)
        CLI::UI::Frame.open('Error') do
          puts "An error occurred: #{error.message}"
          puts "Please check the log file at #{Obsidian::LOG_FILE} for more details"
        end
      end
    end
  end
end
