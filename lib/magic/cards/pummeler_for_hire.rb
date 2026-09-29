module Magic
  module Cards
    PummelerForHire = Creature("Pummeler for Hire") do
      cost generic: 4, green: 1
      creature_type("Giant Mercenary")
      power 4
      toughness 4
      keywords :reach, :vigilance

      ward generic: 2
    end

    class PummelerForHire < Creature
      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          greatest_power = controller.creatures.by_type("Giant").map(&:power).max
          trigger_effect(:gain_life, target: controller, life: greatest_power) if greatest_power.to_i.positive?
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
