# frozen_string_literal: true

require 'obsidian'
require_relative '../../directory_utils'

module Obsidian
  module Commands
    class Sync < Obsidian::Command
      def call(_args, _name)
        dir = DirectoryUtils.vault_dir
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
