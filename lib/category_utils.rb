# frozen_string_literal: true

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
  end
end
