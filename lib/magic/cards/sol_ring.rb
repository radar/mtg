module Magic
  module Cards
    class SolRing < Card
      NAME = "Sol Ring"
      TYPE_LINE = "Artifact"
      COST = { colorless: 1 }

      def tap!
        controller.add_mana(colorless: 2)
        super
      end
    end
  end
end
