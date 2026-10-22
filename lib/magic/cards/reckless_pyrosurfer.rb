module Magic
  module Cards
    RecklessPyrosurfer = Creature("Reckless Pyrosurfer") do
      cost generic: 1, red: 1
      creature_type "Human Scout"
      keywords :haste
      power 2
      toughness 2
    end

    class RecklessPyrosurfer < Creature
      # Landfall -- Whenever a land you control enters, this creature gains battle cry until end of turn.
      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform? = you?

        def call
          give_keyword actor, :battle_cry
        end
      end

      # Battle cry: Whenever this creature attacks, each other attacking creature gets +1/+0 until end of turn. Each
      # instance (one per landfall this turn) triggers separately, so the bonus stacks.
      class BattleCryTrigger < TriggeredAbility
        def should_perform? = event.attacker == actor && actor.has_keyword?(Keywords::BATTLE_CRY)

        def call
          instances = actor.keywords.count { _1 == Keywords::BATTLE_CRY || _1.is_a?(Keywords::BATTLE_CRY) }
          instances.times do
            game.battlefield.creatures.attacking.reject { _1 == actor }.each { pump _1, 1, 0 }
          end
        end
      end

      def event_handlers
        super.merge(Events::Landfall => LandfallTrigger, Events::CreatureAttacked => BattleCryTrigger)
      end
    end
  end
end
