module Magic
  module Cards
    PactOfTheSerpent = Sorcery("Pact of the Serpent") do
      cost "{1}{B}{B}"
    end

    class PactOfTheSerpent < Sorcery
      attr_accessor :chosen_creature_type

      def single_target?
        true
      end

      def target_choices
        game.players
      end

      def resolve!(target:)
        count = target.creatures.by_type(chosen_creature_type).count

        trigger_effect(:draw_cards, player: target, number_to_draw: count)
        trigger_effect(:lose_life, target: target, life: count)
      end
    end
  end
end
