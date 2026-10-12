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
        trigger_effect(:deal_damage, target: target, damage: 2)
        trigger_effect(:deal_damage, target: target.controller, damage: 3) if gift_promised?
      end
    end
  end
end
