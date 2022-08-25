module Magic
  module Cards
    class Annul < Instant
      NAME = "Annul"
      COST = { blue: 1 }

      def single_target?
        true
      end

      def target_choices
        game.stack.select { |c| c.enchantment? || c.artifact? }
      end

      def resolve!(_controller, target:)
        Effects::CounterSpell.new(source: self).resolve(target)
      end
    end
  end
end
