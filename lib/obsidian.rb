require 'cli/ui'
require 'cli/kit'

CLI::UI::StdoutRouter.enable

module Obsidian
  TOOL_NAME = 'obsidian'
  ROOT      = File.expand_path('../..', __FILE__)
  LOG_FILE  = '/tmp/obsidian.log'

  autoload(:EntryPoint, 'obsidian/entry_point')
  autoload(:Commands,   'obsidian/commands')

  Config = CLI::Kit::Config.new(tool_name: TOOL_NAME)
  Command = CLI::Kit::BaseCommand

  Executor = CLI::Kit::Executor.new(log_file: LOG_FILE)
  Resolver = CLI::Kit::Resolver.new(
    tool_name: TOOL_NAME,
    command_registry: Obsidian::Commands::Registry
  )

  ErrorHandler = CLI::Kit::ErrorHandler.new(log_file: LOG_FILE)
end
