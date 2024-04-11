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

      def static_abilities = [ReduceManaCost]

      def event_handlers
        {
          Events::EnteredTheBattlefield => -> (receiver, event) do
            return if event.permanent == receiver
            return unless event.permanent.flying?
            return unless event.permanent.controller == receiver.controller

            receiver.modify_power(1)
            receiver.modify_toughness(1)
          end
        }

      end

    end
  end
end
