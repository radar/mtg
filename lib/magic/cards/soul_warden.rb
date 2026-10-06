module Magic
  module Cards
    SoulWarden = Creature("Soul Warden") do
      cost white: 1
      creature_type "Human Cleric"
      power 1
      toughness 1
    end

    class SoulWarden < Creature
      # "Whenever another creature enters, you gain 1 life." Any creature, whoever controls it.
      class CreatureEnteredTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature?
        end

        def call
          trigger_effect(:gain_life, target: controller, life: 1)
        end
      end

      def event_handlers
        super.merge(Events::EnteredTheBattlefield => CreatureEnteredTrigger)
      end
    end
  end
end
