module Magic
  module Cards
    Flashfreeze = Instant("Flashfreeze") do
      cost generic: 1, blue: 1
    end

    class Flashfreeze < Instant
      def target_choices
        game.stack.spells.select { _1.card.colors.include?(:red) || _1.card.colors.include?(:green) }
      end

      def resolve!(target:)
        trigger_effect(:counter_spell, target: target)
      end
    end
  end
end
