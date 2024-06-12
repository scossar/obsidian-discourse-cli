# frozen_string_literal: true

require 'fileutils'
require 'obsidian'

module Obsidian
  module Commands
    class Sync < Obsidian::Command
      def call(_args, _name)
        dir = vault_dir
      rescue StandardError => e
        rescue_from_error(e)
      end

      def self.help
        "This will be the help text for #{Obsidian::TOOL_NAME}"
      end

      private

      def vault_dir
        answer = ''
        loop do
          answer = CLI::UI::Prompt.ask("Vault root directory (enter 'q' to quit)",
                                       is_file: true).strip
          exit if answer.downcase == 'q'

          if answer.empty?
            message = 'The directory path cannot be empty. Please try again'
            user_error(message)
            next
          end

          expanded_answer = File.expand_path(answer)
          unless File.directory?(expanded_answer)
            message = "The directory '#{answer}' does not exist. Please try again."
            user_error(message)
            next
          end

          confirm = CLI::UI::Prompt.confirm("Is '#{answer}' correct?")
          break if confirm
        end
        answer
      end

      def user_error(message)
        CLI::UI::Frame.open('Error') do
          puts message
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
