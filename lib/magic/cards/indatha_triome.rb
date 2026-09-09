module Magic
  module Cards
    IndathaTriome = Card("Indatha Triome") do
      type T::Land, T::Lands::Plains, T::Lands::Swamp, T::Lands::Forest
      enters_tapped
    end

    class IndathaTriome < Card
      class ManaAbility < Magic::TapManaAbility
        choices :white, :black, :green
      end

      class CyclingAbility < Magic::ActivatedAbility
        def costs
          [
            Costs::Mana.new(generic: 3),
            Costs::Discard.new(source.controller, ->(card) { card == source }),
          ]
        end

        def resolve!
          source.controller.draw!
        end
      end

      def activated_abilities = [ManaAbility, CyclingAbility]
    end
  end
end