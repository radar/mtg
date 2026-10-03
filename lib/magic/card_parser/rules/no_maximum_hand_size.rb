# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "You have no maximum hand size." Marks the card (`no_maximum_hand_size?`); `Player#maximum_hand_size`
      # returns nil while its controller has such a permanent, so the cleanup step's discard skips them.
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
