module Magic
  module Cards
    class Forest < BasicLand
      NAME = "Forest"
      TYPE_LINE = "Basic Land -- Forest"

      class ManaAbility < Magic::TapManaAbility
        choices :green

      end

      def activated_abilities = [ManaAbility]
    end
  end
end
