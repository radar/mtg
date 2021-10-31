module Magic
  module Cards
    class Counterspell < Instant
      NAME = "Counterspell"
      COST = { blue: 2 }

      def target_choices
        game.stack.cards
      end

      def resolve!(target:)
        Effects::CounterSpell.new.resolve(target: target)

        super()
      end
    end
  end
end
