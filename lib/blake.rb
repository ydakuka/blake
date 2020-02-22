# frozen_string_literal: true

require 'blake/version'

require 'blake/main'

module Blake
  def self.digest(input, *args)
    Blake::Main.new(*args).digest(input)
  end
end
