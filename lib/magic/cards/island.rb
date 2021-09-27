module Magic
  module Cards
    class Island < BasicLand
      def initialize(**args)
        super(name: "Island", **args)
      end


      def tap!
        controller.add_mana(blue: 1)
        super
      end
    end
  end
end
