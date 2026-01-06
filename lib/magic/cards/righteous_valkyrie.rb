module Magic
  module Cards
    RighteousValkyrie = Creature("Righteous Valkyrie") do
      cost generic: 2, white: 1
      creature_type "Angel Cleric"
      power 2
      toughness 4
      keywords :flying
    end

    class RighteousValkyrie < Creature
      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        # As long as you have at least 7 life more than your starting life total...
        conditions do
          controller.life >= controller.starting_life + 7
        end
        # ... creatures you control get +2/+2.
        creatures_you_control
        modify power: 2, toughness: 2
      end

      def static_abilities = [PowerAndToughnessModification]

      class AngelOrClericEnters < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && any_type?("Angel", "Cleric")
        end

        def call
          controller.gain_life(event.permanent.toughness)
        end
      end

      def event_handlers
        {
          Events::EnteredTheBattlefield => AngelOrClericEnters
        }
      end
    end
  end
end
