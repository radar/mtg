module Magic
  module Cards
    class Mountain < Card
      NAME = "Mountain"
      TYPE_LINE = "Basic Land -- Mountain"

      def tap!
        controller.add_mana(red: 1)
        super
      end
    end
  end
end
