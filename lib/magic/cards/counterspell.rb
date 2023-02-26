module Magic
  module Cards
    Counterspell = Instant("Counterspell") do
      cost blue: 2
    end

    class Counterspell < Instant
      def single_target?
        true
      end

      def target_choices
        game.stack.spells
      end

      def resolve!(_controller, target:)
        Effects::CounterSpell.new(source: self).resolve(target)

        super
      end
    end
  end
end
