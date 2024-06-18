# frozen_string_literal: true

require 'yaml'

require_relative 'errors'
require_relative 'discourse_request'

module Obsidian
  class FileHandler
    def initialize(markdown)
      @markdown = markdown
      @image_tag_regex = /!\[\[(.*?)\]\]/
      config = YAML.load_file('config/config.yml')
      @uploads_dir = config['uploads_dir']
    end

    def convert
      file_names = []
      file_adjusted = @markdown.gsub(@image_tag_regex) do |tag_match|
        file_name = tag_match.match(@image_tag_regex)[1]
        file_names << file_name
        file_path = "#{@uploads_dir}/#{file_name}"
        response = upload_image(file_path)
        short_url = response['short_url']
        original_filename = response['original_filename']
        new_tag = "![#{original_filename}](#{short_url})"
        new_tag
      rescue StandardError => e
        raise Obsidian::Errors::BaseError,
              "Error processing upload for #{tag_match}: #{e.message}"
      end
      [file_adjusted, file_names]
    end

    private

    def upload_image(image_path)
      puts "Uploading file '#{image_path}'"
      expanded_path = File.expand_path(image_path)
      client = DiscourseRequest.new
      client.upload_file(expanded_path)
    end
  end
end
