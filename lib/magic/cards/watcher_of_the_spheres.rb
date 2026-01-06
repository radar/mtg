module Magic
  module Cards
    class WatcherOfTheSpheres < Creature
      card_name "Watcher of the Spheres"
      creature_type "Bird Wizard"
      cost white: 1, blue: 1
      keywords :flying
      power 2
      toughness 2

      class ReduceManaCost < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          @source = source
          @adjustment = { generic: -1 }
        end

        def applies_to?(card)
          card.is_a?(Card) && card.flying?
        end
      end

      class EnteredTheBattlefieldTrigger < TriggeredAbility::EnterTheBattlefield
        # Whenever another creature you control with flying enters
        def should_perform?
          another_creature? && flying? && under_your_control?
        end

        def call
          actor.modify_power(1)
          actor.modify_toughness(1)
        end
      end

      def static_abilities = [ReduceManaCost]

      def event_handlers
        {
          Events::EnteredTheBattlefield => EnteredTheBattlefieldTrigger
        }
      end
    end
  end
end
