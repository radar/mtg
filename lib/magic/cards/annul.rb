module Magic
  module Cards
    class Annul < Instant
      NAME = "Annul"
      COST = { blue: 1 }

      def target_choices
        game.stack.select { |c| c.enchantment? || c.artifact? }
      end

      def resolve!(target:)
        Effects::CounterSpell.new.resolve(target: target)

        super()
      end
    end
  end
end
