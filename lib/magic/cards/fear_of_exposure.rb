module Magic
  module Cards
    FearOfExposure = Creature("Fear of Exposure") do
      cost generic: 2, green: 1
      enchantment_creature_type("Nightmare")
      keywords :trample
      power 5
      toughness 4
    end

    class FearOfExposure < Creature
      # "As an additional cost to cast this spell, tap two untapped creatures and/or lands you control."
      def additional_costs
        [Costs::MultiTap.new(2) { controller.permanents.untapped.select { _1.creature? || _1.land? } }]
      end
    end
  end
end
