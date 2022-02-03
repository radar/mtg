# frozen_string_literal: true

require_relative "magic/version"

require "state_machines"
require "logger"
require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup # ready!

module Magic
  class Error < StandardError; end
  # Your code goes here...
end
