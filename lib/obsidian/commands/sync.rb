# frozen_string_literal: true

require 'obsidian'
require_relative '../../models/directory'
require_relative '../../category_utils'
require_relative '../../cli_kit_utils'
require_relative '../../directory_utils'
require_relative '../../discourse_category_fetcher'
require_relative '../../errors'
require_relative '../../file_utils'
require_relative '../../publish_to_discourse'
require_relative '../../publisher_utils'

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
        CLI::UI::Frame.open('Configure directory categories') do
          CategoryUtils.directories_for_categories(categories:, category_names:, selected_dirs:)
        end
      end

      def publishing_frames(selected_dirs)
        CLI::UI::Frame.open('Publish to Discourse') do
          selected_dirs.each do |dir|
            PublisherUtils.publish_dir(dir)
          end
        end
      end

      def publish_dir(dir, publisher)
        CLI::UI::Frame.open("Publishing notes from {{green:#{dir}}} ") do
          Dir.glob(File.join(dir, '*.md')).each do |file_path|
            title, _front_matter, markdown = FileUtils.parse_file(file_path)
            spin_group = CLI::UI::SpinGroup.new

            spin_group.failure_debrief do |_title, exception|
              puts CLI::UI.fmt "  #{exception}"
            end

            spin_group.add("Handling uploads for {{green:#{title}}}") do |spinner|
              markdown, file_names = publisher.handle_attachments(markdown)
              spinner_title = uploads_title(file_names, title)
              spinner.update_title(spinner_title)
            end

            spin_group.wait

            spin_group.add("Handling internal links for {{green:#{title}}}") do |spinner|
              markdown, stub_topics = publisher.handle_links(markdown)
              spinner_title = links_title(stub_topics, title)
              spinner.update_title(spinner_title)
            end

            spin_group.wait

            post_id = publisher.post_id_for_note(title)

            if post_id
              spin_group.add("Updating topic for note {{green:#{title}}}") do
                publisher.update_post_from_note(markdown, post_id)
              end
            else
              spin_group.add("Publishing topic for note {{green:#{title}}}") do
                publisher.create_topic(title, markdown)
              end
            end

            spin_group.wait
          end
        end
      end

      private

      def uploads_title(file_names, title)
        if file_names.any?
          file_names = file_names.map { |name| "{{green:#{name}}}" }.join(', ')
          "Uploaded #{file_names} for {{green:#{title}}}"
        else
          "No uploads in {{green:#{title}}}"
        end
      end

      def links_title(stub_topics, title)
        if stub_topics.any?
          topic_names = stub_topics.map { |name| "{{green:#{name}}}" }.join(', ')
          "Generated stub topics for #{topic_names}"
        else
          "No internal links in {{green:#{title}}}"
        end
      end

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
