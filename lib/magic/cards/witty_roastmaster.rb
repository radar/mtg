module Magic
  module Cards
    WittyRoastmaster = Creature("Witty Roastmaster") do
      cost generic: 2, red: 1
      creature_type "Devil Citizen"
      power 3
      toughness 2
    end

    class WittyRoastmaster < Creature
      # Alliance: "Whenever another creature you control enters, this creature deals 1 damage to each opponent."
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
