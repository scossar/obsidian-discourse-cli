# frozen_string_literal: true

require_relative 'models/discourse_category'
require_relative 'models/directory'
require_relative 'discourse_category_fetcher'

module Obsidian
  module CategoryUtils
    def self.category_loader
      spin_group = CLI::UI::SpinGroup.new

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

    def self.directory_category(categories:, category_names:, selected_dirs:)
      current_dir = nil
      selected_dirs.each do |dir|
        current_dir = dir
        loop do
          answer, confirm = category_for_dir(category_names:, dir:)
          return answer if confirm
        end

        category = category_by_name(categories:, name: answer)
        directory = Directory.find_by(path: current_dir)
        result = DiscourseCategory.create(discourse_id: category[:id], name: category[:name],
                                          slug: category[:slug])
        if result.persisted?
          directory.update(discourse_category: result)
          puts CLI::UI.fmt "Directory {{green:#{current_dir}}} is now associated with {{blue:#{category[:name]}}}"
        else
          puts 'Failed to create DiscourseCategory'
        end
      end
    end

    def self.category_for_dir(category_names:, dir:)
      answer = CLI::UI::Prompt.ask("Category for {{green:#{dir}}}?", options: category_names)
      confirm = CLI::UI::Prompt.confirm("Notes from the {{green:#{dir}}} directory will be " \
                                        "published to the {{blue:#{answer}}} category.")

      [answer, confirm]
    end

    def self.category_by_name(categories:, name:)
      categories.each_value do |category|
        return category if category[:name] == name
      end
      nil
    end
  end
end
