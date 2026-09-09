module Magic
  module Cards
    ShelteredThicket = Card("Sheltered Thicket") do
      type T::Land, T::Lands::Mountain, T::Lands::Forest
      enters_tapped
    end

    class ShelteredThicket < Card
      class ManaAbility < Magic::TapManaAbility
        choices :red, :green
      end

      class CyclingAbility < Magic::ActivatedAbility
        costs "{2}"

        def resolve!
          source.controller.draw!
        end
      end

      def activated_abilities = [ManaAbility, CyclingAbility]
    end
  end
end