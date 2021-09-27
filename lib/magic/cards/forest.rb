module Magic
  module Cards
    class Forest < Card
      def initialize(**args)
        super(name: "Forest", **args)
      end

      def tap!
        controller.add_mana(:green)
        super
      end
    end
  end
end
