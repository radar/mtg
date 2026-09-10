module Magic
  module Cards
    RhysTheExiled = Creature("Rhys the Exiled") do
      legendary_creature_type "Elf Warrior"
      cost generic: 2, green: 1
      power 3
      toughness 2
    end

    class RhysTheExiled < Creature
      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { |attack| attack.attacker == actor }
        end

        def call
          elf_count = controller.creatures.count { |c| c.type?("Elf") }
          actor.trigger_effect(:gain_life, life: elf_count) if elf_count.positive?
        end
      end

      class RegenerateAbility < Magic::ActivatedAbility
        costs "{B}, Sacrifice an Elf"

        def resolve!
          source.regenerate!
        end
      end

      def activated_abilities = [RegenerateAbility]

      def event_handlers
        {
          Events::FinalAttackersDeclared => AttackTrigger
        }
      end
    end
  end
end
