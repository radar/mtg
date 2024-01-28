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

      def resolve!(target:)
        trigger_effect(:counter_spell, target: target)

        super
      end
    end
  end
end
