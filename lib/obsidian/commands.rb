require 'obsidian'

module Obsidian
  module Commands
    Registry = CLI::Kit::CommandRegistry.new(default: 'help')

    def self.register(const, cmd, path)
      autoload(const, path)
      Registry.add(->() { const_get(const) }, cmd)
    end

    register :Example, 'example', 'obsidian/commands/example'
    register :Help,    'help',    'obsidian/commands/help'
  end
end
