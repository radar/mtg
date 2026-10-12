module Magic
  module Cards
    class BloomingBlast < Instant
      card_name "Blooming Blast"
      cost generic: 1, red: 1
      gift :treasure

      def target_choices = battlefield.creatures

      # Blooming Blast deals 2 damage to target creature. If the gift was promised, it also deals
      # 3 damage to that creature's controller.
      def resolve!(target:)
        deal_damage(2, to: target)
        deal_damage(3, to: target.controller) if gift_promised?
      end
    end
  end
end
