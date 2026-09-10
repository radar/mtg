module Magic
  module Cards
    WolverineRiders = Creature("Wolverine Riders") do
      creature_type "Elf Warrior"
      cost generic: 4, green: 2
      power 4
      toughness 4
    end

    class WolverineRiders < Creature
      ElfWarriorToken = Token.create "Elf Warrior" do
        creature_type "Elf Warrior"
        power 1
        toughness 1
        colors :green
      end

      class UpkeepTrigger < TriggeredAbility
        def call
          actor.trigger_effect(:create_token, token_class: ElfWarriorToken)
        end
      end

      class ElfEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent != actor && event.permanent.type?("Elf") && under_your_control?
        end

        def call
          actor.trigger_effect(:gain_life, life: event.permanent.toughness)
        end
      end

      def event_handlers
        {
          Events::BeginningOfUpkeep => UpkeepTrigger,
          Events::EnteredTheBattlefield => ElfEntersTrigger
        }
      end
    end
  end
end
