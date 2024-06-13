# frozen_string_literal: true

require 'yaml'

require_relative 'api_error_handler'
require_relative 'discourse_request'

module Obsidian
  class FileHandler
    def initialize(markdown)
      @markdown = markdown
      @image_tag_regex = /!\[\[(.*?)\]\]/
      config = YAML.load_file('config.yml')
      @uploads_dir = config['uploads_dir']
    end

    def convert
      @markdown.gsub(@image_tag_regex) do |tag_match|
        image_name = tag_match.match(@image_tag_regex)[1]
        image_path = "#{@uploads_dir}/#{image_name}"
        response = upload_image(image_path)
        short_url = response['short_url']
        original_filename = response['original_filename']
        new_tag = "![#{original_filename}](#{short_url})"
        new_tag
      rescue StandardError => e
        ApiErrorHandler.handle_error("Error processing upload #{tag_match}: #{e.message}",
                                     'ProcessingError')
        tag_match
      end
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
