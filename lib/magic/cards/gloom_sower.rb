module Magic
  module Cards
    GloomSower = Creature("Gloom Sower") do
      cost generic: 5, black: 2
      creature_type "Horror"
      power 8
      toughness 6
    end

    class GloomSower < Creature
      # "Whenever this creature becomes blocked by a creature, that creature's controller loses 2 life and you gain
      # 2 life." Once for each blocker.
      class BlockedTrigger < TriggeredAbility
        def should_perform? = event.attacker == actor

        def call
          trigger_effect(:lose_life, target: event.blocker.controller, life: 2)
          trigger_effect(:gain_life, life: 2)
        end
      end

      def event_handlers = { Events::CreatureBlocked => BlockedTrigger }
    end
  end
end
