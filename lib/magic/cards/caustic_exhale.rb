module Magic
  module Cards
    CausticExhale = Instant("Caustic Exhale") do
      cost black: 1
    end

    class CausticExhale < Instant
      # As an additional cost to cast this spell, behold a Dragon or pay mana.
      def additional_costs
        [Costs::Behold.new(self, type: "Dragon", or_mana: {:generic=>1})]
      end

      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        trigger_effect(:modify_power_toughness, target: target, power: -3, toughness: -3)
      end
    end
  end
end
