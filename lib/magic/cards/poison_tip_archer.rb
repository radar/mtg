module Magic
  module Cards
    PoisonTipArcher = Creature("Poison-Tip Archer") do
      cost "{2}{B}{G}"
      creature_type "Elf Archer"
      keywords :reach, :deathtouch
      power 2
      toughness 3
    end

    class PoisonTipArcher < Creature
      class CreatureDiedTrigger < TriggeredAbility
        def should_perform?
          event.permanent != actor
        end

        def call
          opponents.each { |opponent| actor.trigger_effect(:lose_life, target: opponent, life: 1) }
        end
      end

      def event_handlers
        { Events::CreatureDied => CreatureDiedTrigger }
      end
    end
  end
end
