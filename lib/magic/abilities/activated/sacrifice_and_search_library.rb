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

        end
      end
    end
  end
end
