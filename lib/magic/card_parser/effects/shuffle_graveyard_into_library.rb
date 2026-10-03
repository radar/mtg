# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Shuffle your graveyard into your library." (Feldon's Cane): every card in the
      # controller's graveyard goes into their library, then the library is shuffled.
      class ShuffleGraveyardIntoLibrary < Data.define
        include Effect

        LINE = /\AShuffle your graveyard into your library\.?\z/i

        def self.parse(text)
          new if LINE.match(text)
        end

        def resolve_call
          "[*controller.graveyard.cards].each { _1.move_zone!(to: controller.library) }\ncontroller.shuffle!"
        end
      end
    end
  end
end
