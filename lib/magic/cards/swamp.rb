module Magic
  module Cards
    class Swamp < BasicLand
      NAME = "Swamp"
      TYPE_LINE = "Basic Land -- Swamp"

      class ManaAbility < Magic::TapManaAbility
        choices :black
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
