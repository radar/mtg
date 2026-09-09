module Magic
  module Cards
    NexusWardens = Creature("Nexus Wardens") do
      cost generic: 2, green: 1
      creature_type "Satyr Archer"
      power 2
      toughness 2
      keywords :reach
    end

    class NexusWardens < Creature
      class ConstellationTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          enchantment? && under_your_control?
        end

        def call
          controller.gain_life(2)
        end
      end

      def event_handlers
        { Events::EnteredTheBattlefield => ConstellationTrigger }
      end
    end
  end
end