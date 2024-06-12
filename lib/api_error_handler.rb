# frozen_string_literal: true

# TODO: this is wrong
module Obsidian
  module ApiErrorHandler
    def self.handle_error(message, error_type)
      puts "Handling error. message: #{message}, type: #{error_type}"
      puts "Error: #{message}"
      case error_type
      when 'invalid_access'
        puts 'Make sure you have added your API key to the .env file'
        exit
      when 'invalid_file'
        puts 'The file provided does not have a .md extension.'
        exit
      else
        prompt_to_continue
      end
    end
  end
end
