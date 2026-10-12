module Magic
  module Cards
    FliThePathfinder = Creature("Fíli the Pathfinder") do
      cost generic: 3, white: 1
      legendary_creature_type("Dwarf Scout")
      power 2
      toughness 2
    end

    class FliThePathfinder < Creature
      # "Storied ... As long as you have an enduring story, creatures you control get +1/+1."
      class StoriedBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applicable_targets { your.creatures }
        conditions { Magic::Storied.enduring_story?(controller) }
      end

      def static_abilities = [StoriedBuff]

      # "Whenever Fíli or another nontoken Dwarf you control enters, create a 2/2 red Dwarf creature token."
      class DwarfEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          under_your_control? && type?("Dwarf") && !event.permanent.token?
        end

        def call
          trigger_effect(:create_token, token_class: Tokens::Dwarf, controller: controller)
        end
      end

      def event_handlers = super.merge(Events::EnteredTheBattlefield => DwarfEntersTrigger)
    end
  end
end
