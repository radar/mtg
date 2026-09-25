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
        trigger_effect(:deal_damage, target: target, damage: 5)
        target.register_turn_replacement(Magic::Effects::MovePermanentZone, Magic::ReplacementEffect::ExileInsteadOfDying)
      end
    end
  end
end
