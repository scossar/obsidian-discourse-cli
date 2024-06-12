require 'obsidian'

module Obsidian
  module EntryPoint
    def self.call(args)
      cmd, command_name, args = Obsidian::Resolver.call(args)
      Obsidian::Executor.call(cmd, command_name, args)
    end
  end
end
