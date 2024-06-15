# frozen_string_literal: true

module Obsidian
  class Note < ActiveRecord::Base
    belongs_to :directory
    has_one :discourse_topic, dependent: :destroy

    validates :title, presence: true, uniqueness: true
  end
end
