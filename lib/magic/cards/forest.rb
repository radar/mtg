module Magic
  module Cards
    class Forest < Card
      NAME = "Forest"
      TYPE_LINE = "Basic Land -- Forest"
      def tap!
        controller.add_mana(green: 1)
        super
      end
    end
  end
end
