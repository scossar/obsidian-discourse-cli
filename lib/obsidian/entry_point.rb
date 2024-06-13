# frozen_string_literal: true

require 'obsidian'
require_relative 'db'

module Obsidian
  module EntryPoint
    def self.call(args)
      DB.setup
      cmd, command_name, args = Obsidian::Resolver.call(args)
      Obsidian::Executor.call(cmd, command_name, args)
    end
  end
end
