# frozen_string_literal: true

module Obsidian
  class DiscourseCategory < ActiveRecord::Base
    has_many :directories

    validates :name, presence: true, uniqueness: true
    validates :discourse_id, presence: true, uniqueness: true
  end
end
