module Magic
  module Cards
    PondProphet = Creature("Pond Prophet") do
      cost blue_or_green: 2
      creature_type("Frog Advisor")
      power 1
      toughness 1
    end

    class PondProphet < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:draw_card)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
