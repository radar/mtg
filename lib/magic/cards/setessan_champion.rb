module Magic
  module Cards
    SetessanChampion = Creature("Setessan Champion") do
      cost generic: 2, green: 1
      creature_type "Human Warrior"
      power 1
      toughness 3
    end

    class SetessanChampion < Creature
      class ConstellationTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          enchantment? && under_your_control?
        end

        def call
          actor.add_counter("+1/+1")
          controller.draw!
        end
      end

      def event_handlers
        { Events::EnteredTheBattlefield => ConstellationTrigger }
      end
    end
  end
end