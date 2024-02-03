module Magic
  module Cards
    class Island < BasicLand
      NAME = "Island"
      TYPE_LINE = "Basic Land -- Island"

      class ManaAbility < Magic::TapManaAbility
        choices :blue
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
