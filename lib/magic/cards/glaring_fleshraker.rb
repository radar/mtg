module Magic
  module Cards
    GlaringFleshraker = Creature("Glaring Fleshraker") do
      cost generic: 2, colorless: 1
      creature_type "Eldrazi Drone"
      power 2
      toughness 2
    end

    class GlaringFleshraker < Creature
      # "Whenever you cast a colorless spell, create a 0/1 colorless Eldrazi Spawn creature token..."
      class SpawnTrigger < TriggeredAbility::SpellCast
        def should_perform? = you? && spell.colorless?

        def call = create_eldrazi_spawn
      end

      # "Whenever another colorless creature you control enters, this creature deals 1 damage to each opponent."
      class PingTrigger < TriggeredAbility
        def should_perform?
          permanent = event.permanent
          permanent != actor && permanent.creature? && permanent.colorless? && permanent.controller == controller
        end

        def call
          game.opponents(controller).each { |opponent| deal_damage(1, to: opponent) }
        end
      end

      def event_handlers
        super.merge(Events::SpellCast => SpawnTrigger, Events::EnteredTheBattlefield => PingTrigger)
      end
    end
  end
end
