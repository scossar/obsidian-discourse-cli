# frozen_string_literal: true

module Obsidian
  module FileUtils
    def self.title_from_file_path(file_path)
      File.basename(file_path, '.md')
    end
  end
end
