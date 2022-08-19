module Magic
  module Cards
    class CloudkinSeer < Creature
      NAME = "Cloudkin Seer"
      COST = { any: 2, blue: 1 }
      TYPE_LINE = "Creature -- Elemental Wizard"
      POWER = 2
      TOUGHNESS = 1
      KEYWORDS = [Keywords::FLYING]

      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          game.add_effect(Effects::DrawCards.new(source: permanent, player: controller))
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
