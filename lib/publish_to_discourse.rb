# frozen_string_literal: true

require 'front_matter_parser'
require 'yaml'

require_relative 'api_error_handler'
require_relative 'discourse_request'
require_relative 'errors'
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
      note = Note.find_by(title:)
      post_id = note&.discourse_topic&.discourse_post_id
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

    def create_topic(title:, markdown:, directory:)
      category_id = fetch_category_id(directory)
      response = create_discourse_topic(title, markdown, category_id)
      note = create_note(title, directory)
      create_discourse_topic_entry(response, note)
    end

    def update_topic_from_note(markdown:, post_id:)
      @client.update_post(markdown:, post_id:)
    end

    private

    def fetch_category_id(directory)
      directory.discourse_category&.discourse_id.tap do |category_id|
        unless category_id
          raise Obsidian::Errors::BaseError,
                "Category ID not found for directory #{directory.path}"
        end
      end
    end

    def create_discourse_topic(title, markdown, category_id)
      @client.create_topic(title:, markdown:, category: category_id).tap do |response|
        raise Obsidian::Errors::BaseError, 'Failed to create Discourse topic' unless response
      end
    rescue StandardError => e
      raise Obsidian::Errors::BaseError, "Error creating Discourse topic: #{e.message}"
    end

    def create_note(title, directory)
      Note.create(title:, directory:).tap do |note|
        raise Obsidian::Errors::BaseError, 'Note could not be created' unless note.persisted?
      end
    rescue StandardError => e
      raise Obsidian::Errors::BaseError, "Error creating Note: #{e.message}"
    end

    def create_discourse_topic_entry(response, note)
      discourse_url = "#{@base_url}/t/#{response['topic_slug']}/#{response['topic_id']}"
      discourse_id = response['topic_id']
      discourse_post_id = response['id']
      DiscourseTopic.create(discourse_url:, discourse_id:,
                            discourse_post_id:, note:).tap do |topic|
        unless topic.persisted?
          raise Obsidian::Errors::BaseError, 'DiscourseTopic could not be created'
        end
      end
    rescue StandardError => e
      raise Obsidian::Errors::BaseError, "Error creating DiscourseTopic: #{e.message}"
    end
  end
end
