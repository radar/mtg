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
          deal_damage(4, to: target)
        else
          deal_damage(2, to: target)
        end
      end
    end
  end
end
