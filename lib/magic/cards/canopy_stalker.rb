module Magic
  module Cards
    CanopyStalker = Creature("Canopy Stalker") do
      cost generic: 3, green: 1
      creature_type "Cat"
      power 4
      toughness 2
    end

    class CanopyStalker < Creature
      # "This creature must be blocked if able."
      def must_be_blocked? = true

      # "When this creature dies, you gain 1 life for each creature that died this turn."
      class DiesTrigger < TriggeredAbility::Death
        def call
          died = game.current_turn.events.count { |event| event.is_a?(Events::CreatureDied) }
          trigger_effect(:gain_life, life: died) if died > 0
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
