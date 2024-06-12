# frozen_string_literal: true

module Obsidian
  module DirectoryUtils
    def self.vault_dir
      loop do
        answer = CLI::UI::Prompt.ask("Vault root directory (enter 'q' to quit)",
                                     is_file: true).strip
        exit if answer.downcase == 'q'

        if answer.empty?
          user_error('The directory path cannot be empty. Please try again.')
          next
        end

        expanded_answer = File.expand_path(answer)
        unless File.directory?(expanded_answer)
          user_error("The directory '#{answer}' does not exist. Please try again.")
          next
        end

        confirm = CLI::UI::Prompt.confirm("Is '#{expanded_answer}' correct?")
        return expanded_answer if confirm
      end
    end

    def self.user_error(message)
      CLI::UI::Frame.open('Error') do
        puts message
      end
    end
  end
end
