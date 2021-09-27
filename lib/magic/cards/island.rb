module Magic
  module Cards
    class Island < BasicLand
      NAME = "Island"
      TYPE_LINE = "Basic Land -- Island"

      def tap!
        controller.add_mana(blue: 1)
        super
      end
    end
  end
end
