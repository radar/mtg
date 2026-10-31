module Magic
  module Cards
    MinesOfMoria = Card("Mines of Moria") do
      type T::Super::Legendary, T::Land
    end

    class MinesOfMoria < Card
      # "This land enters tapped unless you control a legendary creature."
      def enters_tapped? = controller.creatures.none?(&:legendary?)

      # "{T}: Add {R}."
      class ManaAbility < Magic::TapManaAbility
        choices :red
      end

      # "{3}{R}, {T}, Exile three cards from your graveyard: Create two Treasure tokens."
      class TreasureAbility < Magic::ActivatedAbility
        def costs
          [*Costs::Parser.parse(source: source, costs: "{3}{R}, {T}"), Costs::ExileFromGraveyard.new(source, count: 3)]
        end

        def resolve!
          create_token(token: Tokens::Treasure, amount: 2, controller:)
        end
      end

      def activated_abilities = [ManaAbility, TreasureAbility]
    end
  end
end
