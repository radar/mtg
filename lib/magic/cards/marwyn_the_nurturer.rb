module Magic
  module Cards
    MarwynTheNurturer = Creature("Marwyn, the Nurturer") do
      legendary_creature_type "Elf Druid"
      cost generic: 2, green: 1
      power 1
      toughness 1
    end

    class MarwynTheNurturer < Creature
      class ElfEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent != actor && event.permanent.type?("Elf") && under_your_control?
        end

        def call
          actor.trigger_effect(:add_counter, counter_type: "+1/+1", target: actor)
        end
      end

      class ManaAbility < Magic::TapManaAbility
        choices :green

        def mana_produced
          { choice => source.power }
        end
      end

      def event_handlers
        {
          Events::EnteredTheBattlefield => ElfEntersTrigger
        }
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
