module Magic
  module Cards
    class ThoughtweftCharge < Instant
      card_name "Thoughtweft Charge"
      cost generic: 1, green: 1

      def target_choices = battlefield.creatures

      # "Target creature gets +3/+3 until end of turn. If a creature entered the battlefield under
      # your control this turn, draw a card."
      def resolve!(target:)
        trigger_effect(:modify_power_toughness, target:, power: 3, toughness: 3)
        trigger_effect(:draw_card) if creature_entered_this_turn?
      end

      private

      def creature_entered_this_turn?
        game.current_turn.events.any? do |event|
          event.is_a?(Events::EnteredTheBattlefield) && event.permanent.creature? && event.permanent.controller == controller
        end
      end
    end
  end
end
