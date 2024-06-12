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
          user_error("The directory {{red:#{answer}}} does not exist. Please try again.")
          next
        end

        confirm = CLI::UI::Prompt.confirm("Is {{green:#{answer}}} correct?")
        return answer if confirm
      end
    end

    def self.select_subdirs(dir)
      expanded_dir = File.expand_path(dir)
      all_selected_dirs = [expanded_dir]
      process_subdirs(expanded_dir, all_selected_dirs)
      all_selected_dirs
    end

    def self.process_subdirs(current_dir, all_selected_dirs)
      subdirs = find_subdirs(current_dir)

      return unless subdirs.any?

      selected_subdirs = choose_subdirs(current_dir, subdirs)
      selected_subdirs.each do |subdir|
        subdir_path = File.join(current_dir, subdir)
        all_selected_dirs << subdir_path
        process_subdirs(subdir_path, all_selected_dirs)
      end
    end

    def self.find_subdirs(expanded_dir)
      Dir.entries(expanded_dir).select do |entry|
        File.directory?(File.join(expanded_dir,
                                  entry)) && !['.', '..'].include?(entry) && !entry.start_with?('.')
      end
    end

    def self.choose_subdirs(dir, subdirs)
      question = "Select any subdirectories of {{green:#{dir}}} that you would also like to sync"
      CLI::UI::Prompt.ask(question, options: subdirs, allow_empty: true, multiple: true)
    end

    def self.user_error(message)
      CLI::UI::Frame.open('Error') do
        puts CLI::UI.fmt message
      end
    end
  end
end
