module Magic
  module Cards
    ElvishWarmaster = Creature("Elvish Warmaster") do
      creature_type "Elf Warrior"
      cost generic: 1, green: 1
      power 2
      toughness 2
    end

    class ElvishWarmaster < Creature
      ElfWarriorToken = Token.create "Elf Warrior" do
        creature_type "Elf Warrior"
        power 1
        toughness 1
        colors :green
      end

      class ElfEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent != actor && event.permanent.type?("Elf") && under_your_control? && first_qualifying_elf_this_turn?
        end

        def call
          actor.trigger_effect(:create_token, token_class: ElfWarriorToken)
        end

        private

        def first_qualifying_elf_this_turn?
          matching_events.first == event
        end

        def matching_events
          game.current_turn.events.select do |e|
            e.is_a?(Events::EnteredTheBattlefield) && e.permanent != actor && e.permanent.type?("Elf") && e.permanent.controller == controller
          end
        end
      end

      class PumpAbility < Magic::ActivatedAbility
        costs "{5}{G}{G}"

        def resolve!
          controller.creatures.by_any_type("Elf").each do |elf|
            trigger_effect(:modify_power_toughness, power: 2, toughness: 2, target: elf, until_eot: true)
            trigger_effect(:grant_keyword, keyword: :deathtouch, target: elf)
          end
        end
      end

      def event_handlers
        {
          Events::EnteredTheBattlefield => ElfEntersTrigger
        }
      end

      def activated_abilities = [PumpAbility]
    end
  end
end
