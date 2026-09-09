module Magic
  module Cards
    FesteringThicket = Card("Festering Thicket") do
      type T::Land, T::Lands::Swamp, T::Lands::Forest
      enters_tapped
    end

    class FesteringThicket < Card
      class CyclingAbility < Magic::ActivatedAbility
        costs "{2}"

        def resolve!
          source.controller.draw!
        end
      end

      class ManaAbility < Magic::TapManaAbility
        choices :black, :green
      end

      def activated_abilities = [ManaAbility, CyclingAbility]
    end
  end
end