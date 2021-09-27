module Magic
  module Cards
    class GreatFurnace < Land
      NAME = "Great Furnace"
      TYPE_LINE = "Artifact Land"

      def tap!
        controller.add_mana(red: 1)
        super
      end
    end
  end
end
