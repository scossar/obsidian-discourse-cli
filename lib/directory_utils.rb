# frozen_string_literal: true

require_relative 'models/directory'

module Obsidian
  module DirectoryUtils
    def self.vault_dir
      loop do
        answer = CLI::UI::Prompt.ask("Directory to sync (enter 'q' to quit)",
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
      all_selected_dirs = process_subdirs(expanded_dir, all_selected_dirs)
      Directory.ensure_directories_exist(all_selected_dirs)
      all_selected_dirs
    end

    def self.process_subdirs(current_dir, all_selected_dirs)
      subdirs = find_subdirs(current_dir)

      return all_selected_dirs unless subdirs.any?

      selected_subdirs = choose_subdirs(current_dir, subdirs)
      return all_selected_dirs unless selected_subdirs.any?

      selected_subdirs.each do |subdir|
        subdir_path = File.join(current_dir, subdir)
        all_selected_dirs << subdir_path
        process_subdirs(subdir_path, all_selected_dirs)
      end

      all_selected_dirs
    end

    def self.find_subdirs(expanded_dir)
      Dir.entries(expanded_dir).select do |entry|
        File.directory?(File.join(expanded_dir,
                                  entry)) && !['.',
                                               '..'].include?(entry) && !entry.start_with?('.')
      end
    end

    def self.choose_subdirs(dir, subdirs)
      dir_name = File.basename(dir)
      question = "Would you like to sync any subdirectores of {{green:#{dir_name}}}?"
      CLI::UI::Prompt.ask(question, options: subdirs, allow_empty: true, multiple: true)
    end

    # NOTE: I'm keeping this here as a reference
    def self.quote_path(path)
      "\"#{path}\""
    end

    def self.user_error(message)
      CLI::UI::Frame.open('Error') do
        puts CLI::UI.fmt message
      end
    end
  end
end
