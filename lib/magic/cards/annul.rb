module Magic
  module Cards
    Annul = Instant("Annul") do
      cost blue: 1
    end

    class Annul < Instant
      def single_target?
        true
      end

      def target_choices
        game.stack.select { |c| c.enchantment? || c.artifact? }
      end

      def resolve!(target:)
        trigger_effect(:counter_spell, target: target)

      end
    end
  end
end
