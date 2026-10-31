module Magic
  module Cards
    AssaultOnOsgiliath = Sorcery("Assault on Osgiliath") do
      cost x: 1, red: 3
    end

    class AssaultOnOsgiliath < Sorcery
      # "Amass Orcs X, then Goblins and Orcs you control gain double strike and haste until end of turn."
      # The Army is an Orc by then, so it is included.
      def resolve!(value_for_x: 0)
        Magic::Amass.call(source: self, controller: controller, amount: value_for_x, subtype: "Orc")
        game.settle!
        controller.creatures.select { _1.type?("Goblin") || _1.type?("Orc") }.each do |creature|
          give_keyword(creature, :double_strike)
          give_keyword(creature, :haste)
        end
        super()
      end
    end
  end
end
