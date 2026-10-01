module Magic
  module Cards
    RebelliousStrike = Instant("Rebellious Strike") do
      cost generic: 1, white: 1
    end

    class RebelliousStrike < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        trigger_effect(:modify_power_toughness, target: target, power: 3, toughness: 0)
        trigger_effect(:draw_card)
      end
    end
  end
end
