# frozen_string_literal: true

module Obsidian
  class DiscourseTopic < ActiveRecord::Base
    belongs_to :note

    validates :discourse_url, presence: true, uniqueness: true
    validates :discourse_id, presence: true, uniqueness: true
  end
end
