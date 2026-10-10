module Magic
  module Cards
    FearOfIsolation = Creature("Fear of Isolation") do
      cost generic: 1, blue: 1
      enchantment_creature_type("Nightmare")
      keywords :flying
      power 2
      toughness 3
    end

    class FearOfIsolation < Creature
      # "As an additional cost to cast this spell, return a permanent you control to its owner's hand."
      def additional_costs = [Costs::ReturnPermanent.new(self)]
    end
  end
end
