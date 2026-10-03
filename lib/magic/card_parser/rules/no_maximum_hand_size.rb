# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "You have no maximum hand size." The engine has no cleanup-step discard to hand size, so this only marks
      # the card (`no_maximum_hand_size?`) for when it does.
      class NoMaximumHandSize < Data.define
        include Rule

        def self.parse(line)
          new if line.match?(/\AYou have no maximum hand size\.?\z/)
        end

        def kinds = PERMANENT_KINDS
        def body_source = "def no_maximum_hand_size? = true\n"
      end
    end
  end
end
