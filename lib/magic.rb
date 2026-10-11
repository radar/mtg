# frozen_string_literal: true

require_relative "magic/version"

require "state_machines"
require "logger"
require "zeitwerk"
require "dry/types"

loader = Zeitwerk::Loader.for_gem
# Roman numerals in card names: Zeitwerk would camelize meathook_massacre_ii to MeathookMassacreIi.
loader.inflector.inflect("meathook_massacre_ii" => "MeathookMassacreII")
loader.setup # ready!

module Magic
  class Error < StandardError; end
  # Your code goes here...
end

Magic::Randomness.install!
