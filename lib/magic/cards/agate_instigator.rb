module Magic
  module Cards
    AgateInstigator = Creature("Agate Instigator") do
      cost generic: 1, red: 1
      creature_type "Lizard Rogue"
      power 1
      toughness 3
      offspring generic: 1, red: 1
    end

    class AgateInstigator < Creature
      # "Whenever another creature you control enters, this creature deals 1 damage to each opponent."
      class CreatureEnteredTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control?
        end

        def call
          opponents.each { |opponent| actor.deal_damage(1, to: opponent) }
        end
      end

      def event_handlers
        super.merge(Events::EnteredTheBattlefield => CreatureEnteredTrigger)
      end
    end
  end
end
