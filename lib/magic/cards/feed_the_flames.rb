module Magic
  module Cards
    FeedTheFlames = Instant("Feed the Flames") do
      cost generic: 3, red: 1
    end

    class FeedTheFlames < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        deal_damage(5, to: target)
        target.register_turn_replacement(Magic::Effects::MovePermanentZone, Magic::ReplacementEffect::ExileInsteadOfDying)
      end
    end
  end
end
