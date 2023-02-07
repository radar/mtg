module Magic
  module Types
    module Creature

      VALID_TYPES = [
        Cleric = "Cleric",
        Dwarf = "Dwarf",
      ].freeze

      def self.[](*types)
        valid_types = types.select { |type| constants.include?(type) }.map(&:to_s).join(" ")
        "Creature -- #{valid_types}"
      end


    end
  end
end
