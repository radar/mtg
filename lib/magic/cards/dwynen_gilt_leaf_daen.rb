module Magic
  module Cards
    DwynenGiltLeafDaen = Creature("Dwynen, Gilt-Leaf Daen") do
      legendary_creature_type "Elf Warrior"
      cost generic: 2, green: 2
      power 3
      toughness 4
      keywords :reach
    end

    class DwynenGiltLeafDaen < Creature
      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        other_creatures "Elf"
      end

      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { |attack| attack.attacker == actor }
        end

        def call
          attacking_elves = event.attacks.count { |attack| attack.attacker.type?("Elf") && attack.attacker.controller == controller }
          actor.trigger_effect(:gain_life, life: attacking_elves) if attacking_elves.positive?
        end
      end

      def static_abilities = [PowerAndToughnessModification]

      def event_handlers
        {
          Events::FinalAttackersDeclared => AttackTrigger
        }
      end
    end
  end
end
