# frozen_string_literal: true

require_relative('errors')

module Obsidian
  module FileUtils
    def self.title_from_file_path(file_path)
      title = File.basename(file_path, '.md')
      return if title

      raise Obsidian::Errors::BaseError,
            "Title not found for file_pat: #{file_path}"
    end
  end
end
