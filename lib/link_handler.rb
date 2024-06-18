# frozen_string_literal: true

require 'yaml'

require_relative 'errors'
require_relative 'discourse_request'
require_relative 'models/note'

module Obsidian
  class LinkHandler
    def initialize(markdown, directory)
      @markdown = markdown
      @directory = directory
      @internal_link_regex = /(?<!!)\[\[(.*?)\]\]/
      config = YAML.load_file('config/config.yml')
      @base_url = config['base_url']
    end

    def handle
      internal_links = []
      @markdown.gsub(@internal_link_regex) do |link_match|
        title = link_match.match(@internal_link_regex)[1]
        discourse_url = Note.find_by(title:)&.discourse_topic&.discourse_url
        discourse_url ||= placeholder_topic(title)
        new_link = "[#{title}](#{discourse_url})"
        new_link
      rescue StandardError => e
        raise Obsidian::Errors::BaseError,
              "Error converting interal link to relative link: #{e.message}"
      end
      [@markdown, internal_links]
    end

    private

    def placeholder_topic(title)
      markdown = "This is a placeholder topic for #{title}"
      post_data = create_discourse_topic(title, markdown)
      note = create_note(title, @directory)
      create_discourse_topic_entry(post_data, note)
    end

    def create_discourse_topic(title, markdown)
      client = DiscourseRequest.new
      category_id = fetch_category_id(@directory)
      client.create_topic(title:, markdown:, category: category_id).tap do |response|
        unless response
          raise Obsidian::Errors::BaseError,
                "Failed to create linked topic for '#{title}'"
        end
      end
    end

    def create_note(title, directory)
      Note.create(title:, directory:).tap do |note|
        raise Obsidian::Errors::BaseError, 'Note could not be created' unless note.persisted?
      end
    rescue StandardError => e
      raise Obsidian::Errors::BaseError, "Error creating Note: #{e.message}"
    end

    def url_from_post_data(response)
      "#{@base_url}/t/#{response['topic_slug']}/#{response['topic_id']}"
    end

    def create_discourse_topic_entry(post_data, note)
      discourse_url = url_from_post_data(post_data)
      discourse_id = post_data['topic_id']
      discourse_post_id = post_data['id']
      DiscourseTopic.create(discourse_url:, discourse_id:,
                            discourse_post_id:, note:).tap do |topic|
        unless topic.persisted?
          raise Obsidian::Errors::BaseError, 'DiscourseTopic could not be created'
        end
      end
      discourse_url
    rescue StandardError => e
      raise Obsidian::Errors::BaseError, "Error creating DiscourseTopic: #{e.message}"
    end

    def fetch_category_id(directory)
      directory.discourse_category&.discourse_id.tap do |category_id|
        unless category_id
          raise Obsidian::Errors::BaseError,
                "Category ID not found for directory #{directory.path}"
        end
      end
    end
  end
end
