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

      class EnteredTheBattlefieldTrigger < TriggeredAbility
        # TODO: Make this into a neater API like: another_creature? & flying? & under_your_control?
        def should_perform?
          another_creature? && event.permanent.flying? && event.permanent.controller == controller
        end

        def call
          source.modify_power(1)
          source.modify_toughness(1)
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
