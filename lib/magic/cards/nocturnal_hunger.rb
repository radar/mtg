module Magic
  module Cards
    class NocturnalHunger < Instant
      card_name "Nocturnal Hunger"
      cost generic: 2, black: 1
      gift :food

      def target_choices = battlefield.creatures

      # Destroy target creature. If the gift wasn't promised, you lose 2 life.
      def resolve!(target:)
        destroy(target)
        lose_life(controller, 2) unless gift_promised?
      end
    end
  end
end
