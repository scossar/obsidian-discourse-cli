# frozen_string_literal: true

require 'yaml'

require_relative 'discourse_request'
require_relative 'errors'
require_relative 'file_handler'
require_relative 'link_handler'
require_relative 'models/discourse_topic'
require_relative 'models/note'

module Obsidian
  class PublishToDiscourse
    def initialize(directory)
      @directory = directory
      @client = DiscourseRequest.new
      config = YAML.load_file('config/config.yml')
      @base_url = config['base_url']
    end

    def handle_attachments(markdown)
      file_handler = FileHandler.new(markdown)
      file_handler.convert
    end

    def handle_links(markdown)
      link_handler = LinkHandler.new(markdown, @directory)
      link_handler.handle
    end

    def create_topic(title, markdown)
      category_id = fetch_category_id
      response = create_discourse_topic(title, markdown, category_id)
      note = create_note(title)
      create_discourse_topic_entry(response, note)
    end

    def update_post_from_note(markdown, post_id)
      @client.update_post(markdown:, post_id:).tap do |response|
        raise Obsidian::Errors::BaseError, "Failed to update post_id: #{post_id}" unless response
      end
    rescue StandardError => e
      raise Obsidian::Errors::BaseError, "Failed to update topic for Note: #{e.message}"
    end

    private

    def fetch_category_id
      @directory.discourse_category&.discourse_id.tap do |category_id|
        unless category_id
          raise Obsidian::Errors::BaseError,
                "Category ID not found for directory #{@directory.path}"
        end
      end
    end

    def create_discourse_topic(title, markdown, category_id)
      @client.create_topic(title:, markdown:, category: category_id).tap do |response|
        unless response
          raise Obsidian::Errors::BaseError,
                "Failed to create Discourse topic: #{title}"
        end
      end
    rescue StandardError => e
      raise Obsidian::Errors::BaseError, "Error creating Discourse topic: #{e.message}"
    end

    def create_note(title)
      Note.create(title:, directory: @directory).tap do |note|
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
