module Magic
  module Cards
    HorizonExplorer = Creature("Horizon Explorer") do
      cost generic: 2, green: 1
      creature_type "Insect Scout"
      power 3
      toughness 3
    end

    class HorizonExplorer < Creature
      class LanderToken < Token
      end

      def lands_enter_untapped?(card)
        card.land? && card.controller == controller
      end

      def additional_lands_per_turn = 0
    end
  end
end