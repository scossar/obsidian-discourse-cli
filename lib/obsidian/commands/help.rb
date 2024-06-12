# frozen_string_literal: true

require 'obsidian'

module Obsidian
  module Commands
    class Help < Obsidian::Command
      def call(_args, _name)
        puts CLI::UI.fmt('{{bold:Available commands}}')
        puts ''

        Obsidian::Commands::Registry.resolved_commands.each do |name, klass|
          next if name == 'help'

          puts CLI::UI.fmt("{{command:#{Obsidian::TOOL_NAME} #{name}}}")
          if (help = klass.help)
            puts CLI::UI.fmt(help)
          end
          puts ''
        end
      end
    end
  end
end
