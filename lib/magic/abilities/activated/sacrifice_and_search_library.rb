module Magic
  module Abilities
    module Activated
      class SacrificeAndSearchLibrary
        attr_reader :card, :cost

        def initialize(card, cost:)
          @card = card
          @cost = cost
        end

        def activate!
          card.destroy!
          card.game.add_effect(
            Effects::SearchLibraryBasicLandEntersTapped.new(
              library: card.controller.library,
            )
          )
        end
      end
    end
  end
end
