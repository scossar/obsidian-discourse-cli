# frozen_string_literal: true

module Obsidian
  module FileUtils
    def self.title_from_file_path(file_path)
      rails ArgumentError, 'Invalid file extension' unless file_path.end_with?('.md')

      File.basename(file_path, '.md')
    end
  end
end
