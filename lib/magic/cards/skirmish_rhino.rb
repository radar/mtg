module Magic
  module Cards
    SkirmishRhino = Creature("Skirmish Rhino") do
      cost white: 1, black: 1, green: 1
      creature_type("Rhino")
      keywords :trample
      power 3
      toughness 4
    end

    class SkirmishRhino < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.opponents(controller).each { trigger_effect(:lose_life, target: _1, life: 2) }
          trigger_effect(:gain_life, target: controller, life: 2)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
