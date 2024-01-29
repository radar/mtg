module Magic
  module Cards
    TempleOfMalady = Card("Temple of Malady") do
      type "Land"

      enters_the_battlefield do
        game.add_choice(Choice::Scry.new(source: source))
      end
    end

    class TempleOfMalady < Card
      def enters_tapped?
        true
      end

      class ManaAbility < Magic::TapManaAbility
        choices :black, :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
