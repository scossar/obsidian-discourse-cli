# frozen_string_literal: true

module Obsidian
  module Errors
    class BaseError < StandardError; end

    class CategoryNotFoundError < BaseError
      def initialize(directory)
        super("Category ID not found for directory #{directory.path}")
      end
    end
  end
end
