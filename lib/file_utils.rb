# frozen_string_literal: true

require 'front_matter_parser'

require_relative 'cli_kit_utils'

require_relative('errors')

module Obsidian
  module FileUtils
    def self.parse_file(file_path)
      title = title_from_file_path(file_path)

      unless title
        raise Obsidian::Errors::BaseError,
              "Title not found for file_path: #{file_path}"
      end

      content = File.read(file_path)
      markdown, front_matter = parse(content)
      [title, front_matter, markdown]
    end

    def self.title_from_file_path(file_path)
      File.basename(file_path, '.md')
    end

    def self.parse(content)
      parsed = FrontMatterParser::Parser.new(:md).call(content)
      front_matter = parsed.front_matter
      markdown = parsed.content
      [markdown, front_matter]
    end
  end
end
