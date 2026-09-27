module Magic
  module Cards
    class DoseOfDawnglow < Instant
      card_name "Dose of Dawnglow"
      cost generic: 4, black: 1

      def target_choices
        controller.graveyard.cards.select { _1.type?("Creature") }
      end

      # "Then if it isn't your main phase, blight 2."
      def your_main_phase?
        game.current_turn.main_phase? && game.current_turn.active_player == controller
      end

      def resolve!(target:)
        trigger_effect(:return_target_from_graveyard_to_battlefield, target: target)
        return if your_main_phase?

        game.choices.add(Magic::Choice::Blight.new(actor: self, amount: 2)) if Magic::Choice::Blight.possible?(controller, game)
      end
    end
  end
end
