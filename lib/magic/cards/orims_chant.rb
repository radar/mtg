module Magic
  module Cards
    OrimsChant = Instant("Orim's Chant") do
      cost white: 1
      kicker_cost white: 1
    end

    class OrimsChant < Instant
      def target_choices = game.players

      # "Target player can't cast spells this turn. If this spell was kicked, creatures can't attack this turn."
      def resolve!(target:)
        target.limit_spells_this_turn!(0)
        game.current_turn.prevent_attacks! if kicker_cost.paid?
      end
    end
  end
end
