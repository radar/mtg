module Magic
  module Cards
    class LightningBolt < Instant
      NAME = "Lightning Bolt"
      COST = { red: 1 }

      def target_choices
        game.any_target
      end

      def resolve!(target:)
        trigger_effect(:deal_damage, target: target, damage: 3)
      end
    end
  end
end
