module Magic
  module Cards
    class GreatFurnace < Land
      def initialize(**args)
        super(
          name: "Great Furnace",
          type_line: "Artifact Land",
          **args
        )
      end

      def tap!
        controller.add_mana(red: 1)
        super
      end
    end
  end
end
