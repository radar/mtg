module Magic
  module Cards
    class Forest < Card
      NAME = "Forest"
      TYPE_LINE = "Basic Land -- Forest"

      def skip_stack?
        true
      end

      def tap!
        controller.add_mana(:green)
        super
      end
    end
  end
end
