# frozen_string_literal: true

module Obsidian
  module CliKitUtils
    def self.debug(msg)
      logger = CLI::Kit::Logger.new(debug_log_file: '/tmp/obsidian_debug.log')
      logger.debug(msg)
    end
  end
end
