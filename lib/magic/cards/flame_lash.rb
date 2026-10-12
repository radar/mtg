module Magic
  module Cards
    FlameLash = Instant("Flame Lash") do
      cost generic: 3, red: 1
    end

    class FlameLash < Instant
      def target_choices
        game.any_target
      end

      def resolve!(target:)
        trigger_effect(:deal_damage, target: target, damage: 4)
      end
    end
  end
end
