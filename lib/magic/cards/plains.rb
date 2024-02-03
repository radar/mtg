module Magic
  module Cards
    class Plains < BasicLand
      NAME = "Plains"
      TYPE_LINE = "Basic Land -- Plains"

      class ManaAbility < Magic::TapManaAbility
        choices :white
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
