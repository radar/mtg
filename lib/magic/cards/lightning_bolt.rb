module Magic
  module Cards
    class LightningBolt < Instant
      NAME = "Lightning Bolt"
      COST = { red: 1 }

      def target_choices
        game.any_target
      end

      def resolve!(target:)
        deal_damage(3, to: target)
      end
    end
  end
end
