module Magic
  module Cards
    EssenceWarden = Creature("Essence Warden") do
      cost green: 1
      creature_type("Elf Shaman")
      power 1
      toughness 1
    end

    class EssenceWarden < Creature
      class EntersTrigger < TriggeredAbility
        def should_perform?
          event.permanent != actor
        end

        def call
          trigger_effect(:gain_life, source: actor, life: 1)
        end
      end

      def event_handlers
        {
          # Whenever another creature enters the battlefield, you gain 1 life.
          Events::EnteredTheBattlefield => EntersTrigger
        }
      end
    end
  end
end
