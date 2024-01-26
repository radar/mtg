module Magic
  module Cards
    JungleHollow = Card("Jungle Hollow") do
      type "Land"
    end

    class JungleHollow < Card
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
        choices :black, :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
