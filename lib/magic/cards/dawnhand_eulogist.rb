module Magic
  module Cards
    DawnhandEulogist = Creature("Dawnhand Eulogist") do
      cost generic: 3, black: 1
      creature_type("Elf Warlock")
      keywords :menace
      power 3
      toughness 3
    end

    class DawnhandEulogist < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          controller.mill(3)
          if controller.graveyard.cards.any? { |card| card.type?("Elf") }
            game.opponents(controller).each { trigger_effect(:lose_life, target: _1, life: 2) }
            trigger_effect(:gain_life, target: controller, life: 2)
          end
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
