module Magic
  module Cards
    TranquilCove = Card("Tranquil Cove") do
      type "Land"
    end

    class TranquilCove < Card
      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          controller.gain_life(1)
        end
      end

      def etb_triggers = [ETB]

      def enters_tapped?
        true
      end

      class ManaAbility < Magic::TapManaAbility
        choices :white, :blue
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
