module Magic
  module Cards
    BurstLightning = Instant("Burst Lightning") do
      cost red: 1
      kicker_cost generic: 4
    end

    class BurstLightning < Instant
      def target_choices
        game.any_target
      end

      def resolve!(target:)
        if kicker_cost.paid?
          trigger_effect(:deal_damage, target: target, damage: 4)
        else
          trigger_effect(:deal_damage, target: target, damage: 2)
        end
      end
    end
  end
end
