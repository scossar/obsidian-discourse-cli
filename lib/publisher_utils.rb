# frozen_string_literal: true

require_relative 'models/directory'
require_relative 'file_utils'
require_relative 'models/note'
require_relative 'publish_to_discourse'

module Obsidian
  module PublisherUtils
    def self.publish_dir(dir)
      directory = Directory.find_by(path: dir)
      publisher = PublishToDiscourse.new(directory)
      CLI::UI::Frame.open("Publishing notes from the {{green:#{File.basename(dir)}}} directory") do
        iterate_dir(dir, publisher)
      end
    end

    def self.iterate_dir(dir, publisher)
      Dir.glob(File.join(dir, '*.md')).each do |file_path|
        title, _front_matter, markdown = FileUtils.parse_file(file_path)
        spin_group = CLI::UI::SpinGroup.new

        spin_group.failure_debrief do |_title, exception|
          puts CLI::UI.fmt "  #{exception}"
        end

        markdown = uploads_task(spin_group:, title:, markdown:, publisher:)

        markdown = links_task(spin_group:, title:, markdown:, publisher:)

        publish_task(spin_group:, title:, markdown:, publisher:)
      end
    end

    def self.uploads_task(spin_group:, title:, markdown:, publisher:)
      spin_group.add("Handling uploads for #{title}") do |spinner|
        markdown, file_names = publisher.handle_attachments(markdown)
        spinner_title = uploads_title(file_names, title)
        spinner.update_title(spinner_title)
      end
      spin_group.wait
      markdown
    end

    def self.links_task(spin_group:, title:, markdown:, publisher:)
      spin_group.add("Handling internal links for {{green:#{title}}}") do |spinner|
        markdown, stub_topics = publisher.handle_links(markdown)
        spinner_title = links_title(stub_topics, title)
        spinner.update_title(spinner_title)
      end
      spin_group.wait
      markdown
    end

    def self.publish_task(spin_group:, title:, markdown:, publisher:)
      post_id = post_id_for_note(title)
      if post_id
        update_topic(spin_group:, title:, markdown:, publisher:, post_id:)
      else
        publish_new_note(spin_group:, title:, markdown:, publisher:)
      end
    end

    def self.update_topic(spin_group:, title:, markdown:, publisher:, post_id:)
      spin_group.add("Updating topic for note {{green:#{title}}}") do
        publisher.update_post_from_note(markdown, post_id)
      end
      spin_group.wait
    end

    def self.publish_new_note(spin_group:, title:, markdown:, publisher:)
      spin_group.add("Publishing topic for note {{green:#{title}}}") do
        publisher.create_topic(title, markdown)
      end
      spin_group.wait
    end

    def self.uploads_title(file_names, title)
      if file_names.any?
        file_names = file_names.map { |name| "{{green:#{name}}}" }.join(', ')
        "Uploaded #{file_names} for {{green:#{title}}}"
      else
        "No uploads in {{green:#{title}}}"
      end
    end

    def self.links_title(stub_topics, title)
      if stub_topics.any?
        topic_names = stub_topics.map { |name| "{{green:#{name}}}" }.join(', ')
        "Generated stub topics for #{topic_names}"
      else
        "No internal links in {{green:#{title}}}"
      end
    end

    def self.post_id_for_note(title)
      note = Note.find_by(title:)
      note&.discourse_topic&.discourse_post_id
    end
  end
end
