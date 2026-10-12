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
        deal_damage(4, to: target)
      end
    end
  end
end
