module Magic
  module Cards
    EnduringTenacity = Creature("Enduring Tenacity") do
      cost generic: 2, black: 2
      enchantment_creature_type("Snake Glimmer")
      power 4
      toughness 3
    end

    class EnduringTenacity < Creature
      # "Whenever you gain life, target opponent loses that much life."
      class LifeGainTrigger < TriggeredAbility
        def should_perform?
          event.player == controller
        end

        def call
          opponents.each { lose_life(_1, event.life) }
        end
      end

      def event_handlers = { Events::LifeGain => LifeGainTrigger }

      def death_triggers = [TriggeredAbility::EnduringReturn]
    end
  end
end
