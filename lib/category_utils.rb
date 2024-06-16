# frozen_string_literal: true

require_relative 'cli_kit_utils'
require_relative 'models/discourse_category'
require_relative 'models/directory'
require_relative 'discourse_category_fetcher'

module Obsidian
  module CategoryUtils
    def self.category_loader
      spin_group = CLI::UI::SpinGroup.new

      spin_group.failure_debrief do |_title, exception|
        puts CLI::UI.fmt "  #{exception}"
      end

      categories, category_names = nil
      spin_group.add('Fetching Categories') do
        category_fetcher = DiscourseCategoryFetcher.instance
        categories = category_fetcher.categories
        category_names = category_fetcher.category_names
      end

      spin_group.wait
      puts category_names if category_names

      [categories, category_names]
    end

    def self.directories_for_categories(categories:, category_names:, selected_dirs:)
      selected_dirs.each do |dir|
        category = Directory.find_by(path: dir)&.discourse_category
        if category
          display_dir_category(dir:, category:)
        else
          category_name = select_category_for_dir(category_names:, dir:)
          update_directory(categories:, category_name:, dir:)
        end
      end
    end

    def self.display_dir_category(dir:, category:)
      basename = File.basename(dir)
      CLI::UI::Frame.open("{{green:#{basename}}}") do
        puts CLI::UI.fmt "  {{green:#{dir}}} has already been configured to publish notes to " \
                         "{{blue:#{category.name}}}"
      end
    end

    def self.select_category_for_dir(category_names:, dir:)
      category_name, confirm = nil
      basename = File.basename(dir)
      loop do
        CLI::UI::Frame.open("Configuring {{green:#{basename}}}") do
          category_name = CLI::UI::Prompt.ask("Category for {{green:#{dir}}}?",
                                              options: category_names)
          confirm = CLI::UI::Prompt.confirm("Notes from the {{green:#{dir}}} directory will be " \
                                            "published to the {{blue:#{category_name}}} category.")
        end

        return category_name if confirm
      end
    end

    def self.update_directory(categories:, category_name:, dir:)
      category = category_by_name(categories:, category_name:)
      directory = Directory.find_by(path: dir)
      result = DiscourseCategory.find_or_create_by(discourse_id: category[:id], name: category_name,
                                                   slug: category[:slug])
      if result.persisted?
        directory.update(discourse_category: result)
        puts CLI::UI.fmt "Directory {{green:#{dir}}} is now associated with {{blue:#{category_name}}}"
      else
        puts 'Failed to create DiscourseCategory'
      end
    end

    def self.category_by_name(categories:, category_name:)
      categories.each_value do |category|
        return category if category[:name] == category_name
      end
      nil
    end
  end
end
