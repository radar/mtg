module Magic
  module Cards
    class GreatFurnace < Land
      NAME = "Great Furnace"
      TYPE_LINE = "Artifact Land"

      class ManaAbility < Magic::ManaAbility
        costs "{T}"
        choices :red
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
