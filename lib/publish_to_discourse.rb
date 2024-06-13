# frozen_string_literal: true

require 'front_matter_parser'

require_relative 'api_error_handler'
require_relative 'discourse_request'
require_relative 'file_utils'

module Obsidian
  class PublishToDiscourse
    def initialize
      @client = DiscourseRequest.new
    end

    def publish(file_path, category_id)
      begin
        title = FileUtils.title_from_file_path(file_path)
      rescue ArgumentError => e
        CliErrorHandler.handle_error(e.message, 'invalid_file')
        return
      end
      content = File.read(file_path)
      # post_id = Database.get_discourse_post_id(title)
      post_id = nil
      markdown, _front_matter = parse(content)
      #  file_handler = FileHandler.new(markdown)
      #  markdown = file_handler.convert
      #  link_handler = LinkHandler.new(markdown)
      #  markdown = link_handler.handle
      if post_id
        update_topic_from_note(title:, markdown:, post_id:)
      else
        create_topic(title:, markdown:, category: category_id)
      end
    end

    def parse(content)
      parsed = FrontMatterParser::Parser.new(:md).call(content)
      front_matter = parsed.front_matter
      markdown = parsed.content
      [markdown, front_matter]
    end

    def create_topic(title:, markdown:, category:)
      puts "Creating full topic for '#{title}'"
      @client.create_topic(title:, markdown:, category:)
      #  add_note_to_db(title, response)
    end

    def update_topic_from_note(title:, markdown:, post_id:)
      puts "Updating post for '#{title}', post_id: #{post_id}"
      @client.update_post(markdown:, post_id:)
    end
  end
end
