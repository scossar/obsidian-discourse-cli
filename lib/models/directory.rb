# frozen_string_literal: true

module Obsidian
  class Directory < ActiveRecord::Base
    belongs_to :discourse_category, optional: true
    has_many :notes

    validates :path, presence: true, uniqueness: true
  end
end
