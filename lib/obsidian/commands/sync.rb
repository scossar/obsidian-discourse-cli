# frozen_string_literal: true

require 'fileutils'
require 'obsidian'

module Obsidian
  module Commands
    class Sync < Obsidian::Command
      def call(_args, _name)
        loop do
          answer = CLI::UI::Prompt.ask("Vault root directory (enter 'q' to quit)", is_file: true)
          exit if answer.downcase == 'q'

          if answer.strip.empty?
            CLI::UI::Frame.open('Error') do
              puts 'The directory path cannot be empty. Please try again.'
            end
            next
          end

          expanded_answer = File.expand_path(answer.strip)

          unless File.directory?(expanded_answer)
            CLI::UI::Frame.open('Error') do
              puts "The directory '#{answer}' does not exist or is not a directory. Please try again."
            end
            next
          end

          confirm = CLI::UI::Prompt.confirm("Is '#{answers}' correct?")

          break if confirm
        end
      rescue StandardError => e
        handle_error(e)
      end

      def self.help
        "This will be the help text for #{Obsidian::TOOL_NAME}"
      end

      def handle_error(error)
        CLI::UI::Frame.open('Error') do
          puts "An error occurred: #{error.message}"
          puts "Please check the log file at #{Obsidian::LOG_FILE} for more details"
        end
      end
    end
  end
end
