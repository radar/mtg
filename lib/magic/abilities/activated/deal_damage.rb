module Magic
  module Abilities
    module Activated
      class DealDamage
        attr_reader :source, :cost

        def initialize(source, cost:)
          @source = source
          @cost = cost
        end

        def activate!
          card.game.add_effect(
            Effects::DealDamage.new(
              choices: game.battlefield.cards + [game.players],
              library: card.controller.library,
            )
          )
        end
      end
    end
  end
end
