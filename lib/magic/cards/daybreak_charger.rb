module Magic
  module Cards
    DaybreakCharger = Creature("Daybreak Charger") do
      cost generic: 1, white: 1
      creature_type("Unicorn")
      power 3
      toughness 1
    end

    class DaybreakCharger < Creature
      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          effect = Effects::ApplyPowerToughnessModification.new(source: self, power: 2, choices: battlefield.creatures)
          game.add_effect(effect)
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
