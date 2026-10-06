module Magic
  module Cards
    BattlefieldForge = Card("Battlefield Forge") do
      type "Land"
    end

    class BattlefieldForge < Card
      class ColorlessManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      class ColoredManaAbility < Magic::TapManaAbility
        choices :red, :white

        def resolve!
          super
          controller.lose_life(1)
        end
      end

      def activated_abilities = [ColorlessManaAbility, ColoredManaAbility]
    end
  end
end
