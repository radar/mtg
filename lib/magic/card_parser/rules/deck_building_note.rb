# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "A deck can have any number of cards named ~." (Hare Apparent): deck construction only, so it
      # generates nothing.
      class DeckBuildingNote < Data.define
        include Rule

        LINE = /\AA deck can have any number of cards named ~\.?\z/

        def self.parse(line)
          new if LINE.match?(line)
        end
      end
    end
  end
end
