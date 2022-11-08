module Magic
  module Cards
    CloudkinSeer = Creature("Cloudkin Seer") do
      cost generic: 2, blue: 1
      type "Creature -- Elemental Wizard"
      power 2
      toughness 1
      keywords :flying
    end

    class CloudkinSeer < Creature
      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          game.add_effect(Effects::DrawCards.new(source: permanent, player: controller))
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
