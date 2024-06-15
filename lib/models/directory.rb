# frozen_string_literal: true

module Obsidian
  class Directory < ActiveRecord::Base
    belongs_to :discourse_category, optional: true
    has_many :notes, dependent: :destroy

    validates :path, presence: true, uniqueness: true

    def self.ensure_directories_exist(paths)
      paths.each do |path|
        find_or_create_by(path:)
      end
    end
  end
end
