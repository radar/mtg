module Magic
  module Cards
    TheShire = Card("The Shire") do
      type T::Super::Legendary, T::Land
    end

    class TheShire < Card
      # "The Shire enters tapped unless you control a legendary creature."
      def enters_tapped? = controller.creatures.none?(&:legendary?)

      # "{T}: Add {G}."
      class ManaAbility < Magic::TapManaAbility
        choices :green
      end

      # "{1}{G}, {T}, Tap an untapped creature you control: Create a Food token."
      class FoodAbility < Magic::ActivatedAbility
        def costs
          [
            Costs::Mana.new(generic: 1, green: 1),
            Costs::SelfTap.new(source),
            Costs::MultiTap.new(1) { controller.creatures.untapped }
          ]
        end

        def resolve!
          create_token(token: Tokens::Food)
        end
      end

      def activated_abilities = [ManaAbility, FoodAbility]
    end
  end
end
