module Magic
  module Cards
    CanyonSlough = Card("Canyon Slough") do
      type T::Land, T::Lands::Swamp, T::Lands::Mountain
      enters_tapped
    end

    class CanyonSlough < Card
      class ManaAbility < Magic::TapManaAbility
        choices :black, :red
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