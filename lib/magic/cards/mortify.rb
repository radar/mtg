module Magic
  module Cards
    Mortify = Instant("Mortify") do
      cost generic: 1, white: 1, black: 1
      type "Instant"
    end

    class Mortify < Instant
      def target_choices
        battlefield.cards.by_any_type("Creature", "Enchantment")
      end

      def single_target?
        true
      end

      def resolve!(target:)
        target.destroy!
      end
    end
  end
end
