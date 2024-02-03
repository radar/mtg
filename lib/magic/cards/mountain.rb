module Magic
  module Cards
    class Mountain < BasicLand
      NAME = "Mountain"
      TYPE_LINE = "Basic Land -- Mountain"

      class ManaAbility < Magic::TapManaAbility
        choices :red
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
