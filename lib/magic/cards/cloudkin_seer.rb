module Magic
  module Cards
    class CloudkinSeer < Creature
      NAME = "Cloudkin Seer"
      COST = { any: 2, blue: 1 }
      TYPE_LINE = "Creature -- Elemental Wizard"
      POWER = 2
      TOUGHNESS = 1
      KEYWORDS = [Keywords::FLYING]

      def entered_the_battlefield!
        add_effect("DrawCards", player: controller)

        super
      end
    end
  end
end
