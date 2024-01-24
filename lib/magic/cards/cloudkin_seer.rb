module Magic
  module Cards
    CloudkinSeer = Creature("Cloudkin Seer") do
      cost generic: 2, blue: 1
      creature_type("Elemental Wizard")
      power 2
      toughness 1
      keywords :flying
    end

    class CloudkinSeer < Creature
      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          permanent.trigger_effect(:draw_cards)
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
