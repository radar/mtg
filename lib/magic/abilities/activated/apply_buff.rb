module Magic
  module Abilities
    module Activated
      class ApplyBuff
        attr_reader :card, :cost, :power, :toughness, :until_eot

        def initialize(card, cost:, power:, toughness:, until_eot:)
          @card = card
          @cost = cost
          @power = power
          @toughness = toughness
        end

        def activate!
          card.modifiers << self
        end
      end
    end
  end
end
