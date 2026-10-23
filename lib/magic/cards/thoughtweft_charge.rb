module Magic
  module Cards
    class ThoughtweftCharge < Instant
      card_name "Thoughtweft Charge"
      cost generic: 1, green: 1

      def target_choices = battlefield.creatures

      # "Target creature gets +3/+3 until end of turn. If a creature entered the battlefield under
      # your control this turn, draw a card."
      def resolve!(target:)
        pump(target, 3, 3)
        draw_card if creature_entered_this_turn?
      end
    end
  end
end
