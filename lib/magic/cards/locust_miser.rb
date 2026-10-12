module Magic
  module Cards
    LocustMiser = Creature("Locust Miser") do
      cost generic: 2, black: 2
      creature_type "Rat Shaman"
      power 2
      toughness 2
    end

    class LocustMiser < Creature
      # "Each opponent's maximum hand size is reduced by two." (`Player#maximum_hand_size` asks the opponents' permanents.)
      def opponents_maximum_hand_size_reduction = 2
    end
  end
end
