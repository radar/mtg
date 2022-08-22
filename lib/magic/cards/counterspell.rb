module Magic
  module Cards
    class Counterspell < Instant
      NAME = "Counterspell"
      COST = { blue: 2 }

      def target_choices
        game.stack.spells
      end

      def single_target?
        true
      end

      def resolve!(target:)
        Effects::CounterSpell.new(source: self).resolve(target)

        super()
      end
    end
  end
end
