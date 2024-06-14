# frozen_string_literal: true

require 'front_matter_parser'
require 'yaml'

require_relative 'api_error_handler'
require_relative 'discourse_request'
require_relative 'file_handler'
require_relative 'file_utils'
require_relative 'models/discourse_topic'
require_relative 'models/note'

module Obsidian
  class PublishToDiscourse
    def initialize
      @client = DiscourseRequest.new
      config = YAML.load_file('config/config.yml')
      @base_url = config['base_url']
    end

    def publish(file_path:, directory:)
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
      file_handler = FileHandler.new(markdown)
      markdown = file_handler.convert
      #  link_handler = LinkHandler.new(markdown)
      #  markdown = link_handler.handle
      if post_id
        update_topic_from_note(markdown:, post_id:)
      else
        create_topic(title:, markdown:, directory:)
      end
    end

    def parse(content)
      parsed = FrontMatterParser::Parser.new(:md).call(content)
      front_matter = parsed.front_matter
      markdown = parsed.content
      [markdown, front_matter]
    end

    # TODO: this needs error handling to prevent duplicate note creation
    def create_topic(title:, markdown:, directory:)
      category = directory.discourse_category.discourse_id
      response = @client.create_topic(title:, markdown:, category:)
      note = Note.create(title:, directory:)
      discourse_url = "#{@base_url}/t/#{response['topic_slug']}/#{response['topic_id']}"
      discourse_id = response['topic_id']
      discourse_post_id = response['id']
      DiscourseTopic.create(discourse_url:, discourse_id:, discourse_post_id:, note:)
    end

    def update_topic_from_note(markdown:, post_id:)
      @client.update_post(markdown:, post_id:)
    end
  end
end
