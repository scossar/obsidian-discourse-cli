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

        confirm = CLI::UI::Prompt.confirm("Is '#{answer}' correct?")
        # NOTE: I think the rest of the code can work with the unexpanded answer
        # return [answer, expanded_answer] if it causes issues
        return answer if confirm
      end
    end

    def self.sync_subdirs(dir)
      expanded_dir = File.expand_path(dir)
      subdirs = Dir.entries(expanded_dir).select do |entry|
        File.directory?(File.join(expanded_dir, entry)) && !['.', '..'].include?(entry)
      end

      if subdirs.any?
        question = "Select any subdirectories of #{dir} that you would also like to sync"
        selected_subdirs = CLI::UI::Prompt.ask(question, options: subdirs, allow_empty: true,
                                                         multiple: true)

        selected_paths = selected_subdirs.map { |subdir| File.join(expanded_dir, subdir) }
        [expanded_dir] + selected_paths
      else
        [expanded_dir]
      end
    end

    def self.user_error(message)
      CLI::UI::Frame.open('Error') do
        puts message
      end
    end
  end
end
