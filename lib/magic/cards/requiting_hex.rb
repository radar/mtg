module Magic
  module Cards
    class RequitingHex < Instant
      card_name "Requiting Hex"
      cost black: 1

      def kicker_cost
        @blight_kicker_cost ||= Costs::BlightKicker.new(amount: 1)
      end

      def target_choices
        battlefield.creatures.select { |creature| creature.mana_value <= 2 }
      end

      def resolve!(target:)
        trigger_effect(:destroy_target, target: target)
        controller.gain_life(2) if kicker_cost.paid?
      end
    end
  end
end
