module Magic
  module Cards
    class Cancel < Instant
      NAME = "Cancel"
      COST = { blue: 2, generic: 1 }

      def single_target?
        true
      end

      def target_choices
        game.stack.spells
      end

      def resolve!(target:)
        Effects::CounterSpell.new(source: self).resolve(target)
      end
    end
  end
end
