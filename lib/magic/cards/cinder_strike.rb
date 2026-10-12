module Magic
  module Cards
    class CinderStrike < Sorcery
      card_name "Cinder Strike"
      cost red: 1

      def kicker_cost
        @blight_kicker_cost ||= Costs::BlightKicker.new(amount: 1)
      end

      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        deal_damage(kicker_cost.paid? ? 4 : 2, to: target)
      end
    end
  end
end
