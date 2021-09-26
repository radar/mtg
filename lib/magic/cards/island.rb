module Magic
  module Cards
    class Island < Card
      def initialize(**args)
        super(name: "Island", **args)
      end

      def tap!
        controller.add_mana(:blue)
      end
    end
  end
end
