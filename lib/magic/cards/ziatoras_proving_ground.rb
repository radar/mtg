module Magic
  module Cards
    ZiatorasProvingGround = Card("Ziatora's Proving Ground") do
      type T::Land, T::Lands::Swamp, T::Lands::Mountain, T::Lands::Forest
      enters_tapped
    end

    class ZiatorasProvingGround < Card
      class ManaAbility < Magic::TapManaAbility
        choices :black, :red, :green
      end

      class CyclingAbility < Magic::ActivatedAbility
        costs "{3}"

        def resolve!
          source.controller.draw!
        end
      end

      def activated_abilities = [ManaAbility, CyclingAbility]
    end
  end
end