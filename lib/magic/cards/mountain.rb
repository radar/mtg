module Magic
  module Cards
    class Mountain < Card
      def initialize(**args)
        super(name: "Mountain", **args)
      end

      def tap!
        controller.add_mana(:red)
      end
    end
  end
end
